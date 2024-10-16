// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:async";
import "dart:typed_data";

import "package:coap/coap.dart" as coap;
import "package:coap/config/coap_config_default.dart";
import "package:dcaf/dcaf.dart";

import "../../core.dart";

import "coap_binding_exception.dart";
import "coap_config.dart";
import "coap_definitions.dart";
import "coap_extensions.dart";
import "coap_subscription.dart";

class _InternalCoapConfig extends CoapConfigDefault {
  _InternalCoapConfig(CoapConfig coapConfig)
      : preferredBlockSize =
            coapConfig.blocksize ?? coap.CoapConstants.preferredBlockSize,
        dtlsCiphers = coapConfig.dtlsCiphers,
        dtlsVerify = coapConfig.dtlsVerify,
        dtlsWithTrustedRoots = coapConfig.dtlsWithTrustedRoots,
        rootCertificates = coapConfig.rootCertificates,
        clientCertificateFileName = coapConfig.clientCertificateFileName,
        clientKeyFileName = coapConfig.clientKeyFileName,
        _verifyPrivateKey = coapConfig.verifyPrivateKey;

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

  @override
  final String? clientCertificateFileName;

  @override
  final String? clientKeyFileName;

  final bool _verifyPrivateKey;

  @override
  bool get verifyPrivateKey => _verifyPrivateKey;
}

coap.PskCredentialsCallback? _createPskCallback(
  Uri uri,
  AugmentedForm? form, {
  ClientPskCallback? pskCredentialsCallback,
}) {
  final usesPskScheme = form?.usesPskScheme ?? false;

  if (!usesPskScheme || pskCredentialsCallback == null) {
    return null;
  }

  return (identityHint) {
    final PskCredentials? pskCredentials =
        pskCredentialsCallback(uri, form, identityHint);

    if (pskCredentials == null) {
      throw CoapBindingException(
        "Missing PSK credentials for CoAPS request!",
      );
    }

    return coap.PskCredentials(
      identity: pskCredentials.identity,
      preSharedKey: pskCredentials.preSharedKey,
    );
  };
}

/// A [ProtocolClient] for the Constrained Application Protocol (CoAP).
final class CoapClient extends ProtocolClient
    with DirectDiscoverer, MulticastDiscoverer, CoreLinkFormatDiscoverer {
  /// Creates a new [CoapClient] based on an optional [CoapConfig].
  CoapClient({
    CoapConfig? coapConfig,
    ClientPskCallback? pskCredentialsCallback,
    AceSecurityCallback? aceSecurityCallback,
  })  : _pskCredentialsCallback = pskCredentialsCallback,
        _aceSecurityCallback = aceSecurityCallback,
        _coapConfig = coapConfig;

  final CoapConfig? _coapConfig;

  final ClientPskCallback? _pskCredentialsCallback;

  final AceSecurityCallback? _aceSecurityCallback;

  Future<coap.CoapRequest> _createRequest(
    coap.RequestMethod requestMethod,
    Uri uri, {
    Content? content,
    coap.CoapMediaType? format,
    coap.CoapMediaType? accept,
    coap.BlockSize? block1Size,
    coap.BlockSize? block2Size,
  }) async {
    final payload = await content?.toByteList();

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
    AugmentedForm form,
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
    required AugmentedForm? form,
    coap.CoapMediaType? format,
    coap.CoapMediaType? accept,
    coap.BlockSize? block1Size,
    coap.BlockSize? block2Size,
    coap.CoapMulticastResponseHandler? multicastResponseHandler,
  }) async {
    final coapClient = coap.CoapClient(
      uri,
      config: _InternalCoapConfig(_coapConfig ?? const CoapConfig()),
      pskCredentialsCallback: _createPskCallback(
        uri,
        form,
        pskCredentialsCallback: _pskCredentialsCallback,
      ),
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
    final aceCredentialsCallback = _aceSecurityCallback;

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
    required AugmentedForm? form,
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
    AugmentedForm form,
  ) async {
    final requestMethod = (form.method ?? CoapRequestMethod.get).code;

    final creationHintUri = form.resolvedHref.replace(scheme: "coap");

    final request = await _createRequest(
      requestMethod,
      creationHintUri,
      format: form.contentFormat,
      accept: form.accept,
    );

    final coapClient = coap.CoapClient(
      creationHintUri,
      config: _InternalCoapConfig(_coapConfig ?? const CoapConfig()),
    );

    final response = await coapClient.send(request);
    coapClient.close();

    return response.creationHint;
  }

  /// Obtains an ACE creation hint serialized as a [List] of [int] from a
  /// [form].
  ///
  /// Returns `null` if no `ACESecurityScheme` is defined.
  Future<AuthServerRequestCreationHint?> _obtainAceCreationHintFromForm(
    AugmentedForm? form,
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

    final textScopes = aceSecurityScheme.scopes?.join(" ");
    // TODO: Do the scopes defined for a form need to be considered here as
    //       well?
    TextScope? scope;
    if (textScopes != null) {
      scope = TextScope(textScopes);
    }

    return AuthServerRequestCreationHint(
      authorizationServer:
          aceSecurityScheme.as?.toString() ?? creationHint?.authorizationServer,
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
    AugmentedForm? form, [
    AceCredentials? invalidAceCredentials,
  ]) async {
    final aceCredentials = await aceCredentialsCallback(
      uri,
      form,
      creationHint,
      invalidAceCredentials,
    );

    if (aceCredentials == null) {
      throw CoapBindingException("Missing ACE-OAuth Credentials");
    }

    final pskCredentials = aceCredentials.accessToken.pskCredentials;

    final client = coap.CoapClient(
      request.uri.replace(scheme: "coaps"),
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
    AugmentedForm? form,
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
  Future<Content> readResource(AugmentedForm form) async {
    return _sendRequestFromForm(form, OperationType.readproperty);
  }

  @override
  Future<void> writeResource(AugmentedForm form, Content content) async {
    await _sendRequestFromForm(form, OperationType.writeproperty, content);
  }

  @override
  Future<Content> invokeResource(AugmentedForm form, Content content) async {
    return _sendRequestFromForm(form, OperationType.invokeaction, content);
  }

  @override
  Future<Subscription> subscribeResource(
    AugmentedForm form, {
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
    AugmentedForm form,
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
      config: _InternalCoapConfig(_coapConfig ?? const CoapConfig()),
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

  @override
  Future<DiscoveryContent> discoverDirectly(Uri uri) async =>
      _sendDiscoveryRequest(
        uri,
        coap.RequestMethod.get,
        form: null,
        accept: coap.CoapMediaType.applicationTdJson,
      );

  @override
  Stream<DiscoveryContent> discoverWithCoreLinkFormat(Uri uri) async* {
    coap.CoapMulticastResponseHandler? multicastResponseHandler;
    final streamController = StreamController<DiscoveryContent>();

    // TODO: Replace once https://github.com/shamblett/coap/pull/129 is merged
    if (uri.hasMulticastAddress) {
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

    if (uri.hasMulticastAddress) {
      yield* streamController.stream;
    } else {
      yield content;
    }
  }

  @override
  Stream<Content> discoverViaMulticast(Uri uri) async* {
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
}
