// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:async';
import 'dart:typed_data';

import 'package:coap/coap.dart' as coap;
import 'package:coap/config/coap_config_default.dart';
import 'package:dcaf/dcaf.dart';

import '../core/content.dart';
import '../core/credentials/ace_credentials.dart';
import '../core/credentials/psk_credentials.dart';
import '../core/protocol_interfaces/protocol_client.dart';
import '../core/security_provider.dart';
import '../definitions/form.dart';
import '../definitions/operation_type.dart';
import '../scripting_api/subscription.dart';
import 'coap_binding_exception.dart';
import 'coap_config.dart';
import 'coap_definitions.dart';
import 'coap_extensions.dart';
import 'coap_subscription.dart';

class _InternalCoapConfig extends CoapConfigDefault {
  _InternalCoapConfig(CoapConfig coapConfig)
      : preferredBlockSize =
            coapConfig.blocksize ?? coap.CoapConstants.preferredBlockSize,
        dtlsCiphers = coapConfig.dtlsCiphers,
        dtlsVerify = coapConfig.dtlsVerify,
        dtlsWithTrustedRoots = coapConfig.dtlsWithTrustedRoots,
        rootCertificates = coapConfig.rootCertificates;

  @override
  final int preferredBlockSize;

  @override
  final String? dtlsCiphers;

  @override
  final bool dtlsVerify;

  @override
  final bool dtlsWithTrustedRoots;

  @override
  final List<Uint8List> rootCertificates;
}

coap.PskCredentialsCallback? _createPskCallback(
  Uri uri,
  Form? form,
  ClientSecurityProvider? clientSecurityProvider,
) {
  final usesPskScheme = form?.usesPskScheme ?? false;
  final pskCredentialsCallback = clientSecurityProvider?.pskCredentialsCallback;

  if (!usesPskScheme || pskCredentialsCallback == null) {
    return null;
  }

  return (identityHint) {
    final PskCredentials? pskCredentials =
        pskCredentialsCallback(uri, form, identityHint);

    if (pskCredentials == null) {
      throw CoapBindingException(
        'Missing PSK credentials for CoAPS request!',
      );
    }

    return coap.PskCredentials(
      identity: pskCredentials.identity,
      preSharedKey: pskCredentials.preSharedKey,
    );
  };
}

/// A [ProtocolClient] for the Constrained Application Protocol (CoAP).
final class CoapClient implements ProtocolClient {
  /// Creates a new [CoapClient] based on an optional [CoapConfig].
  CoapClient([this._coapConfig, this._clientSecurityProvider]);

  final CoapConfig? _coapConfig;

  final ClientSecurityProvider? _clientSecurityProvider;

  Future<coap.CoapRequest> _createRequest(
    coap.RequestMethod requestMethod,
    Uri uri, {
    Content? content,
    coap.CoapMediaType? format,
    coap.CoapMediaType? accept,
    coap.BlockSize? block1Size,
    coap.BlockSize? block2Size,
  }) async {
    final payload = (await content?.byteBuffer)?.asUint8List();

    final request = coap.CoapRequest(
      uri,
      requestMethod,
      payload: payload,
    )
      ..accept = accept
      ..contentFormat = format;

    if (block1Size != null) {
      request.block1 = coap.Block1Option.fromParts(0, block1Size);
    }

    if (block2Size != null) {
      request.block2 = coap.Block2Option.fromParts(0, block2Size);
    }

    return request;
  }

  Future<Content> _sendRequestFromForm(
    Form form,
    OperationType operationType, [
    Content? content,
  ]) async {
    final requestMethod = form.method ?? operationType.requestMethod;
    final code = requestMethod.code;

    return _sendRequest(
      form.resolvedHref,
      code,
      content: content,
      format: form.contentFormat,
      accept: form.accept,
      block1Size: form.block1Size,
      block2Size: form.block2Size,
      form: form,
    );
  }

  // TODO(JKRhb): blockwise parameters cannot be handled at the moment due to
  //              limitations of the CoAP library
  Future<Content> _sendRequest(
    Uri uri,
    coap.RequestMethod method, {
    Content? content,
    required Form? form,
    coap.CoapMediaType? format,
    coap.CoapMediaType? accept,
    coap.BlockSize? block1Size,
    coap.BlockSize? block2Size,
    coap.CoapMulticastResponseHandler? multicastResponseHandler,
  }) async {
    final coapClient = coap.CoapClient(
      uri,
      config: _InternalCoapConfig(_coapConfig ?? CoapConfig()),
      pskCredentialsCallback:
          _createPskCallback(uri, form, _clientSecurityProvider),
    );

    final request = await _createRequest(
      method,
      uri,
      content: content,
      format: format,
      accept: accept,
      block1Size: block1Size,
      block2Size: block2Size,
    );

    final creationHint = await _obtainAceCreationHintFromForm(form);
    final aceCredentialsCallback =
        _clientSecurityProvider?.aceCredentialsCallback;

    final coap.CoapResponse response;

    if (aceCredentialsCallback != null && creationHint != null) {
      response = await _sendAceOauthRequest(
        request,
        creationHint,
        aceCredentialsCallback,
        uri,
        form,
      );
    } else {
      response = await coapClient.send(
        request,
        onMulticastResponse: multicastResponseHandler,
      );
    }

    coapClient.close();
    response.checkResponseCode();
    return response.content;
  }

  Future<DiscoveryContent> _sendDiscoveryRequest(
    Uri uri,
    coap.RequestMethod method, {
    Content? content,
    required Form? form,
    coap.CoapMediaType? format,
    coap.CoapMediaType? accept,
    coap.BlockSize? block1Size,
    coap.BlockSize? block2Size,
    coap.CoapMulticastResponseHandler? multicastResponseHandler,
  }) async {
    final responseContent = await _sendRequest(
      uri,
      method,
      content: content,
      form: form,
      format: format,
      accept: accept,
      block1Size: block1Size,
      block2Size: block2Size,
      multicastResponseHandler: multicastResponseHandler,
    );

    return DiscoveryContent.fromContent(responseContent, uri);
  }

  Future<AuthServerRequestCreationHint?> _obtainCreationHintFromResourceServer(
    Form form,
  ) async {
    final requestMethod = (form.method ?? CoapRequestMethod.get).code;

    final creationHintUri = form.resolvedHref.replace(scheme: 'coap');

    final request = await _createRequest(
      requestMethod,
      creationHintUri,
      format: form.contentFormat,
      accept: form.accept,
    );

    final coapClient = coap.CoapClient(
      creationHintUri,
      config: _InternalCoapConfig(_coapConfig ?? CoapConfig()),
    );

    final response = await coapClient.send(request);
    coapClient.close();

    return response.creationHint;
  }

  /// Obtains an ACE creation hint serialized as a [List] of [int] from a
  /// [Form].
  ///
  /// Returns `null` if no `ACESecurityScheme` is defined.
  Future<AuthServerRequestCreationHint?> _obtainAceCreationHintFromForm(
    Form? form,
  ) async {
    if (form == null) {
      return null;
    }

    final aceSecuritySchemes = form.aceSecuritySchemes;

    if (aceSecuritySchemes.isEmpty) {
      return null;
    }

    final aceSecurityScheme = aceSecuritySchemes.first;

    AuthServerRequestCreationHint? creationHint;

    if (aceSecurityScheme.cnonce ?? false) {
      creationHint = await _obtainCreationHintFromResourceServer(form);
    }

    final textScopes = aceSecurityScheme.scopes?.join(' ');
    // TODO: Do the scopes defined for a form need to be considered here as
    //       well?
    TextScope? scope;
    if (textScopes != null) {
      scope = TextScope(textScopes);
    }

    return AuthServerRequestCreationHint(
      authorizationServer:
          aceSecurityScheme.as ?? creationHint?.authorizationServer,
      scope: scope ?? creationHint?.scope,
      audience: aceSecurityScheme.audience ?? creationHint?.audience,
      clientNonce: creationHint?.clientNonce,
    );
  }

  Future<coap.CoapResponse> _sendAceOauthRequest(
    coap.CoapRequest request,
    AuthServerRequestCreationHint? creationHint,
    AceSecurityCallback aceCredentialsCallback,
    Uri uri,
    Form? form, [
    AceCredentials? invalidAceCredentials,
  ]) async {
    final aceCredentials = await aceCredentialsCallback(
      uri,
      form,
      creationHint,
      invalidAceCredentials,
    );

    if (aceCredentials == null) {
      throw CoapBindingException('Missing ACE-OAuth Credentials');
    }

    final pskCredentials = aceCredentials.accessToken.pskCredentials;

    final client = coap.CoapClient(
      request.uri.replace(scheme: 'coaps'),
      pskCredentialsCallback: (identityHint) => pskCredentials,
    );

    final response = await client.send(request);
    client.close();

    return _handleResponse(
      request,
      response,
      uri,
      form,
      aceCredentialsCallback,
      invalidAceCredentials: aceCredentials,
    );
  }

  Future<coap.CoapResponse> _handleResponse(
    coap.CoapRequest request,
    coap.CoapResponse response,
    Uri uri,
    Form? form,
    AceSecurityCallback aceCredentialsCallback, {
    AceCredentials? invalidAceCredentials,
  }) async {
    if (response.isSuccess) {
      return response;
    }

    if (response.code.isServerError) {
      throw CoapServerErrorException(response);
    }

    final aceCreationHint = response.creationHint;

    if (aceCreationHint != null) {
      if (invalidAceCredentials != null ||
          form == null ||
          form.usesAutoScheme) {
        return _sendAceOauthRequest(
          request,
          aceCreationHint,
          aceCredentialsCallback,
          uri,
          form,
          invalidAceCredentials,
        );
      }
    }

    throw CoapClientErrorException(response);
  }

  @override
  Future<Content> readResource(Form form) async {
    return _sendRequestFromForm(form, OperationType.readproperty);
  }

  @override
  Future<void> writeResource(Form form, Content content) async {
    await _sendRequestFromForm(form, OperationType.writeproperty, content);
  }

  @override
  Future<Content> invokeResource(Form form, Content content) async {
    return _sendRequestFromForm(form, OperationType.invokeaction, content);
  }

  @override
  Future<Subscription> subscribeResource(
    Form form, {
    required void Function(Content content) next,
    void Function(Exception error)? error,
    required void Function() complete,
  }) async {
    final OperationType operationType = form.op.firstWhere(
      (element) => [OperationType.subscribeevent, OperationType.observeproperty]
          .contains(element),
      orElse: () => throw CoapBindingException(
        "Subscription form contained neither 'subscribeevent' "
        "nor 'observeproperty' operation type.",
      ),
    );

    return _startObservation(form, operationType, next, complete);
  }

  Future<CoapSubscription> _startObservation(
    Form form,
    OperationType operationType,
    void Function(Content content) next,
    void Function() complete,
  ) async {
    void handleResponse(coap.CoapResponse? response) {
      if (response == null) {
        return;
      }

      next(response.content);
    }

    final request = await _createRequest(
      (form.method ?? CoapRequestMethod.get).code,
      form.resolvedHref,
      format: form.contentFormat,
      accept: form.accept,
    );

    final subprotocol = form.coapSubprotocol ?? operationType.subprotocol;

    final coapClient = coap.CoapClient(
      form.resolvedHref,
      config: _InternalCoapConfig(_coapConfig ?? CoapConfig()),
    );

    if (subprotocol == CoapSubprotocol.observe) {
      final observeClientRelation = await coapClient.observe(request);
      observeClientRelation.listen(handleResponse);
      return CoapSubscription(coapClient, observeClientRelation, complete);
    }

    final response = await coapClient.send(request);
    handleResponse(response);
    return CoapSubscription(coapClient, null, complete);
  }

  @override
  Future<void> start() async {
    // Do nothing
  }

  @override
  Future<void> stop() async {}

  Stream<DiscoveryContent> _discoverFromMulticast(
    coap.CoapClient client,
    Uri uri,
  ) async* {
    final streamController = StreamController<DiscoveryContent>();
    final multicastResponseHandler = coap.CoapMulticastResponseHandler(
      (data) {
        streamController.add(data.determineDiscoveryContent(uri.scheme));
      },
      onError: streamController.addError,
      onDone: () async {
        await streamController.close();
      },
    );

    final content = _sendDiscoveryRequest(
      uri,
      coap.RequestMethod.get,
      form: null,
      accept: coap.CoapMediaType.applicationTdJson,
      multicastResponseHandler: multicastResponseHandler,
    );
    unawaited(content);
    yield* streamController.stream;
  }

  Stream<DiscoveryContent> _discoverFromUnicast(
    coap.CoapClient client,
    Uri uri,
  ) async* {
    yield await _sendDiscoveryRequest(
      uri,
      coap.RequestMethod.get,
      form: null,
      accept: coap.CoapMediaType.applicationTdJson,
    );
  }

  @override
  Stream<DiscoveryContent> discoverDirectly(
    Uri uri, {
    bool disableMulticast = false,
  }) async* {
    final client = coap.CoapClient(uri);

    if (uri.isMulticastAddress) {
      if (!disableMulticast) {
        yield* _discoverFromMulticast(client, uri);
      }
    } else {
      yield* _discoverFromUnicast(client, uri);
    }
  }

  @override
  Stream<DiscoveryContent> discoverWithCoreLinkFormat(Uri uri) async* {
    coap.CoapMulticastResponseHandler? multicastResponseHandler;
    final streamController = StreamController<DiscoveryContent>();

    // TODO: Replace once https://github.com/shamblett/coap/pull/129 is merged
    if (uri.isMulticastAddress) {
      multicastResponseHandler = coap.CoapMulticastResponseHandler(
        (data) {
          streamController.add(data.determineDiscoveryContent(uri.scheme));
        },
        onError: streamController.addError,
        onDone: () async {
          await streamController.close();
        },
      );
    }

    final content = await _sendDiscoveryRequest(
      uri,
      coap.RequestMethod.get,
      form: null,
      accept: coap.CoapMediaType.applicationLinkFormat,
      multicastResponseHandler: multicastResponseHandler,
    );

    if (uri.isMulticastAddress) {
      yield* streamController.stream;
    } else {
      yield content;
    }
  }
}
