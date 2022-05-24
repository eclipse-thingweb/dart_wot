// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:coap/coap.dart' as coap;
import 'package:coap/config/coap_config_default.dart';
import 'package:curie/curie.dart';
import 'package:dart_wot/src/definitions/credentials/psk_credentials.dart';

import '../core/content.dart';
import '../core/operation_type.dart';
import '../core/protocol_interfaces/protocol_client.dart';
import '../core/thing_discovery.dart';
import '../definitions/form.dart';
import '../definitions/thing_description.dart';
import '../scripting_api/interaction_options.dart';
import '../scripting_api/subscription.dart';
import 'coap_config.dart';

const _blockwiseVocabularyName = "blockwise";
const _validBlockwiseValues = [16, 32, 64, 128, 256, 512, 1024];

final _coapPrefixMapping =
    PrefixMapping(defaultPrefixValue: "http://www.example.org/coap-binding#");

// TODO(JKRhb): Name could be adjusted
enum _ContentFormatType {
  format("format"),
  accept("accept");

  final String stringValue;

  const _ContentFormatType(this.stringValue);
}

// TODO(JKRhb): Name could be adjusted
enum _BlockwiseParameterType {
  block1Size("block2SZX"),
  block2Size("block1SZX");

  final String stringValue;

  const _BlockwiseParameterType(this.stringValue);
}

/// Defines the available CoAP request methods.
enum CoapRequestMethod {
  /// Corresponds with the GET request method.
  get,

  /// Corresponds with the PUT request method.
  put,

  /// Corresponds with the POST request method.
  post,

  /// Corresponds with the DELETE request method.
  delete,

  /// Corresponds with the FETCH request method.
  fetch,

  /// Corresponds with the PATCH request method.
  patch,

  /// Corresponds with the iPATCH request method.
  ipatch,
}

/// Enumeration of available CoAP subprotocols.
enum _Subprotocol {
  /// Subprotocol for observing CoAP resources.
  observe,
}

extension _CoapRequestMethodExtension on CoapRequestMethod {
  coap.CoapRequest generateRequest() {
    switch (this) {
      case CoapRequestMethod.get:
        return coap.CoapRequest.newGet();
      case CoapRequestMethod.post:
        return coap.CoapRequest.newPost();
      case CoapRequestMethod.put:
        return coap.CoapRequest.newPut();
      case CoapRequestMethod.delete:
        return coap.CoapRequest.newDelete();
      default:
        throw UnimplementedError();
    }
  }
}

/// This [Exception] is thrown when an error within the CoAP Binding occurs.
// TODO(JRKhb): Move somewhere else
// TODO(JRKhb): Consider inheriting from a generic BindingException
class CoapBindingException implements Exception {
  final String _message;

  /// Constructor.
  ///
  /// A [_message] can be passed, which will be displayed when the exception is
  /// not caught/propagated.
  CoapBindingException(this._message);

  @override
  String toString() {
    return "$runtimeType: $_message";
  }
}

class _InternalCoapConfig extends CoapConfigDefault {
  @override
  int preferredBlockSize;

  @override
  coap.DtlsBackend? dtlsBackend;

  final Form _form;

  _InternalCoapConfig(CoapConfig coapConfig, this._form)
      : preferredBlockSize =
            coapConfig.blocksize ?? coap.CoapConstants.preferredBlockSize {
    if (!_dtlsNeeded) {
      return;
    }

    if (_hasPskCredentials(_form) && coapConfig.useTinyDtls) {
      dtlsBackend = coap.DtlsBackend.TinyDtls;
    } else if (coapConfig.useOpenSsl) {
      dtlsBackend = coap.DtlsBackend.OpenSsl;
    }
  }

  bool get _dtlsNeeded => _form.resolvedHref.scheme == "coaps";
}

bool _hasPskCredentials(Form form) {
  return form.credentials.whereType<PskCredentials>().isNotEmpty;
}

class _CoapRequest {
  /// The [CoapClient] which sends out request messages.
  final coap.CoapClient _coapClient;

  /// The [Uri] describing the endpoint for the request.
  final Uri _requestUri;

  /// A reference to the [Form] that is the basis for this request.
  final Form _form;

  /// The [CoapRequestMethod] used in the request message (e. g.
  /// [CoapRequestMethod.get] or [CoapRequestMethod.post]).
  final CoapRequestMethod _requestMethod;

  /// The subprotocol that should be used for requests.
  final _Subprotocol? _subprotocol;

  /// Creates a new [_CoapRequest]
  _CoapRequest(
    this._form,
    this._requestMethod,
    CoapConfig _coapConfig, [
    this._subprotocol,
  ])  : _coapClient = coap.CoapClient(
            _form.resolvedHref, _InternalCoapConfig(_coapConfig, _form),
            pskCredentialsCallback: _createPskCallback(_form)),
        _requestUri = _form.resolvedHref;

  // TODO(JKRhb): blockwise parameters cannot be handled at the moment due to
  //              limitations of the CoAP library
  Future<coap.CoapResponse> _makeRequest(
    String? payload, {
    int format = coap.CoapMediaType.textPlain,
    int accept = coap.CoapMediaType.textPlain,
    int? block1Size,
    int? block2Size,
  }) async {
    final coap.CoapResponse? response;
    switch (_requestMethod) {
      case CoapRequestMethod.get:
        response = await _coapClient.get(_requestUri.path,
            earlyBlock2Negotiation: true, accept: accept);
        break;
      case CoapRequestMethod.post:
        payload ??= "";
        response = await _coapClient.post(_requestUri.path,
            payload: payload, format: format);
        break;
      case CoapRequestMethod.put:
        payload ??= "";
        response = await _coapClient.put(_requestUri.path,
            payload: payload, format: format);
        break;
      case CoapRequestMethod.delete:
        response = await _coapClient.delete(_requestUri.path);
        break;
      default:
        throw UnimplementedError(
            "CoAP request method $_requestMethod is not supported yet.");
    }
    _coapClient.close();
    if (response == null) {
      throw CoapBindingException("Sending CoAP request to $_requestUri failed");
    }
    return response;
  }

  static coap.PskCredentials? _retrievePskCredentials(Form form) {
    final pskCredentialsList = form.credentials.whereType<PskCredentials>();

    for (final pskCredentials in pskCredentialsList) {
      final identity =
          pskCredentials.identity ?? pskCredentials.securityScheme?.identity;

      if (identity == null) {
        continue;
      }

      final preSharedKey = pskCredentials.preSharedKey;

      return coap.PskCredentials(
          identity: identity, preSharedKey: preSharedKey);
    }

    return null;
  }

  static coap.PskCredentialsCallback? _createPskCallback(Form form) {
    if (!_hasPskCredentials(form)) {
      return null;
    }

    final pskCredentials = _retrievePskCredentials(form);

    if (pskCredentials == null) {
      throw CoapBindingException("No client Identity found for CoAPS request!");
    }

    // TODO(JKRhb): Should the identityHint be handled?
    return (identityHint) => pskCredentials;
  }

  int _determineContentFormat(_ContentFormatType _contentFormatType) {
    final curieString =
        _coapPrefixMapping.expandCurieString(_contentFormatType.stringValue);
    final dynamic formDefinition = _form.additionalFields[curieString];
    if (formDefinition is int) {
      return formDefinition;
    } else if (formDefinition is List<int>) {
      return formDefinition[0];
    }

    return coap.CoapMediaType.parse(_form.contentType) ??
        coap.CoapMediaType.textPlain;
  }

  int? _determineBlockSize(_BlockwiseParameterType _blockwiseParameterType) {
    final curieString =
        _coapPrefixMapping.expandCurieString(_blockwiseVocabularyName);
    final dynamic formDefinition = _form.additionalFields[curieString];

    if (formDefinition is! Map<String, dynamic>) {
      return null;
    }

    final blockwiseParameterName = _coapPrefixMapping
        .expandCurieString(_blockwiseParameterType.stringValue);
    final dynamic value = formDefinition[blockwiseParameterName];

    if (value is int && !_validBlockwiseValues.contains(value)) {
      return value;
    }

    return null;
  }

  // TODO(JKRhb): Revisit name of this method
  Future<Content> resolveInteraction(String? payload) async {
    final contentFormat = _determineContentFormat(_ContentFormatType.format);
    final acceptFormat = _determineContentFormat(_ContentFormatType.accept);
    final block1Size = _determineBlockSize(_BlockwiseParameterType.block1Size);
    final block2Size = _determineBlockSize(_BlockwiseParameterType.block2Size);

    final response = await _makeRequest(payload,
        format: contentFormat,
        accept: acceptFormat,
        block1Size: block1Size,
        block2Size: block2Size);
    final type = coap.CoapMediaType.name(response.contentFormat);
    final body = _getPayloadFromResponse(response);
    return Content(type, body);
  }

  Future<_CoapSubscription> startObservation(
      void Function(Content content) next, void Function() complete) async {
    void handleResponse(coap.CoapResponse? response) {
      if (response == null) {
        return;
      }

      final type = coap.CoapMediaType.name(response.contentFormat);
      final body = _getPayloadFromResponse(response);
      final content = Content(type, body);
      next(content);
    }

    final requestContentFormat =
        _determineContentFormat(_ContentFormatType.format);

    if (_subprotocol == _Subprotocol.observe) {
      final request = _requestMethod.generateRequest()
        ..contentFormat = requestContentFormat;
      final observeClientRelation = await _coapClient.observe(request);
      observeClientRelation.stream.listen((event) {
        handleResponse(event.resp);
      });
      return _CoapSubscription(_coapClient, observeClientRelation, complete);
    }

    final response = await _makeRequest(null, format: requestContentFormat);
    handleResponse(response);
    return _CoapSubscription(_coapClient, null, complete);
  }

  /// Aborts the request and closes the client.
  ///
  // TODO(JKRhb): Check if this is actually enough
  void abort() {
    _coapClient.close();
  }
}

Stream<List<int>> _getPayloadFromResponse(coap.CoapResponse response) {
  if (response.payload != null) {
    return Stream.value(response.payload!);
  } else {
    return Stream.empty();
  }
}

/// A [ProtocolClient] for the Constrained Application Protocol (CoAP).
class CoapClient extends ProtocolClient {
  final List<_CoapRequest> _pendingRequests = [];
  final CoapConfig? _coapConfig;

  /// Creates a new [CoapClient] based on an optional [CoapConfig].
  CoapClient([this._coapConfig]);

  _CoapRequest _createRequest(Form form, OperationType operationType) {
    final requestMethod = _getRequestMethod(form, operationType);
    final _Subprotocol? subprotocol =
        _determineSubprotocol(form, operationType);
    final coapConfig = _coapConfig ?? CoapConfig();
    final request = _CoapRequest(form, requestMethod, coapConfig, subprotocol);
    _pendingRequests.add(request);
    return request;
  }

  Future<String> _getInputFromContent(Content content) async {
    final inputBuffer = await content.byteBuffer;
    return utf8.decoder
        .convert(inputBuffer.asUint8List().toList(growable: false));
  }

  @override
  Future<Content> readResource(Form form) async {
    final request = _createRequest(form, OperationType.readproperty);
    return await request.resolveInteraction(null);
  }

  @override
  Future<void> writeResource(Form form, Content content) async {
    final request = _createRequest(form, OperationType.writeproperty);
    final input = await _getInputFromContent(content);
    await request.resolveInteraction(input);
  }

  @override
  Future<Content> invokeResource(Form form, Content content) async {
    final request = _createRequest(form, OperationType.invokeaction);
    final input = await _getInputFromContent(content);
    return await request.resolveInteraction(input);
  }

  @override
  Future<Subscription> subscribeResource(
    Form form, {
    required void Function(Content content) next,
    void Function(Exception error)? error,
    required void Function() complete,
  }) async {
    final OperationType operationType = _determineSubscribeOperationType(form);

    final request = _createRequest(form, operationType);

    return await request.startObservation(next, complete);
  }

  static OperationType _determineSubscribeOperationType(Form form) {
    final op = form.op ?? [];
    if (op.contains("subscribeevent")) {
      return OperationType.subscribeevent;
    } else if (op.contains("observeproperty")) {
      return OperationType.observeproperty;
    }

    throw ArgumentError("Subscription form contained neither 'subscribeevent'"
        "nor 'observeproperty' operation type.");
  }

  @override
  Future<void> start() async {
    // Do nothing
  }

  @override
  Future<void> stop() async {
    for (final request in _pendingRequests) {
      request.abort();
    }
    _pendingRequests.clear();
  }

  ThingDescription _handleDiscoveryResponse(
      coap.CoapResponse? response, Uri uri) {
    final rawThingDescription = response?.payloadString;

    if (response == null) {
      throw DiscoveryException("Direct CoAP Discovery from $uri failed!");
    }

    return ThingDescription(rawThingDescription);
  }

  Stream<ThingDescription> _discoverFromMulticast(
      coap.CoapClient client, Uri uri) async* {
    // TODO(JKRhb): This method currently does not work with block-wise transfer
    //               due to a bug in the CoAP library.
    final streamController = StreamController<ThingDescription>();
    final request = coap.CoapRequest(coap.CoapCode.get, confirmable: false)
      // ignore: invalid_use_of_protected_member
      ..uri = uri
      ..accept = coap.CoapMediaType.applicationTdJson;
    final multicastResponseHandler = coap.CoapMulticastResponseHandler(
        (data) {
          final thingDescription = _handleDiscoveryResponse(data.resp, uri);
          streamController.add(thingDescription);
        },
        onError: streamController.addError,
        onDone: () async {
          await streamController.close();
        });

    final response =
        client.send(request, onMulticastResponse: multicastResponseHandler);
    unawaited(response);
    unawaited(
      Future.delayed(
          _coapConfig?.multicastDiscoveryTimeout ?? Duration(seconds: 20), () {
        client
          ..cancel(request)
          ..close();
      }),
    );
    yield* streamController.stream;
  }

  Future<ThingDescription> _discoverFromUnicast(
      coap.CoapClient client, Uri uri) async {
    final response = await client.get(uri.path,
        accept: coap.CoapMediaType.applicationTdJson);
    client.close();
    return _handleDiscoveryResponse(response, uri);
  }

  @override
  Stream<ThingDescription> discoverDirectly(Uri uri) async* {
    final config = CoapConfigDefault();
    final client = coap.CoapClient(uri, config);

    if (uri.isMulticastAddress) {
      yield* _discoverFromMulticast(client, uri);
    } else {
      yield await _discoverFromUnicast(client, uri);
    }
  }
}

extension _InternetAddressMethods on Uri {
  /// Checks whether the host of this [Uri] is a multicast [InternetAddress].
  bool get isMulticastAddress {
    return InternetAddress.tryParse(host)?.isMulticast ?? false;
  }
}

_Subprotocol? _determineSubprotocol(Form form, OperationType operationType) {
  if ([
    OperationType.subscribeevent,
    OperationType.unsubscribeevent,
    OperationType.observeproperty,
    OperationType.unobserveproperty
  ].contains(operationType)) {
    return _Subprotocol.observe;
  }

  if (form.additionalFields["subprotocol"] ==
      _coapPrefixMapping.expandCurieString("observe")) {
    return _Subprotocol.observe;
  }

  return null;
}

CoapRequestMethod _requestMethodFromOperationType(OperationType operationType) {
  switch (operationType) {
    case OperationType.readproperty:
    case OperationType.readmultipleproperties:
    case OperationType.readallproperties:
      return CoapRequestMethod.get;
    case OperationType.writeproperty:
    case OperationType.writemultipleproperties:
      return CoapRequestMethod.put;
    case OperationType.invokeaction:
      return CoapRequestMethod.post;
    case OperationType.observeproperty:
    case OperationType.unobserveproperty:
      return CoapRequestMethod.get;
    case OperationType.subscribeevent:
    case OperationType.unsubscribeevent:
      return CoapRequestMethod.get;
  }
}

CoapRequestMethod? _requestMethodFromString(String formDefinition) {
  // TODO(JKRhb): Handle FETCH, PATCH, and iPATCH
  switch (formDefinition) {
    case "POST":
      return CoapRequestMethod.post;
    case "PUT":
      return CoapRequestMethod.put;
    case "DELETE":
      return CoapRequestMethod.delete;
    case "GET":
      return CoapRequestMethod.get;
    default:
      return null;
  }
}

CoapRequestMethod _getRequestMethod(Form form, OperationType operationType) {
  final curieString =
      _coapPrefixMapping.expandCurie(Curie(reference: "method"));
  final dynamic formDefinition = form.additionalFields[curieString];
  if (formDefinition is String) {
    final requestMethod = _requestMethodFromString(formDefinition);
    if (requestMethod != null) {
      return requestMethod;
    }
  }

  return _requestMethodFromOperationType(operationType);
}

class _CoapSubscription implements Subscription {
  final coap.CoapClient _coapClient;

  final coap.CoapObserveClientRelation? _observeClientRelation;

  bool _active;

  @override
  bool get active => _active;

  /// Callback used to pass by the servient that is used to signal it that an
  /// observation has been cancelled.
  final void Function() _complete;

  _CoapSubscription(
      this._coapClient, this._observeClientRelation, this._complete)
      : _active = true;

  @override
  Future<void> stop([InteractionOptions? options]) async {
    final observeClientRelation = _observeClientRelation;
    if (observeClientRelation != null) {
      await _coapClient.cancelObserveProactive(observeClientRelation);
    }
    _coapClient.close();
    _active = false;
    _complete();
  }
}
