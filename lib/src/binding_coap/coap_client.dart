// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:convert';
import 'dart:io';

import 'package:coap/coap.dart' as coap;
import 'package:coap/config/coap_config_default.dart';

import '../core/content.dart';
import '../core/credentials.dart';
import '../core/operation_type.dart';
import '../core/protocol_interfaces/protocol_client.dart';
import '../definitions/form.dart';
import '../definitions/security_scheme.dart';
import '../scripting_api/interaction_options.dart';
import '../scripting_api/subscription.dart';
import 'coap_config.dart';

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

class _CoapRequest {
  /// The [CoapClient] which sends out request messages.
  late final coap.CoapClient _coapClient = _getCoapClient(_requestUri);

  /// The [Uri] describing the endpoint for the request.
  final Uri _requestUri;

  /// The actual [coap.CoapRequest] object.
  final coap.CoapRequest _coapRequest;

  /// A reference to the [Form] that is the basis for this request.
  final Form _form;

  /// The [CoapRequestMethod] used in the request message (e. g.
  /// [CoapRequestMethod.get] or [CoapRequestMethod.post]).
  final CoapRequestMethod _requestMethod;

  /// An (optional) custom [CoapConfig] which overrides the default values.
  final CoapConfig? _coapConfig;

  /// The subprotocol that should be used for requests.
  final _Subprotocol? _subprotocol;

  /// This [defaultCoapConfig] is used if parameters should not be set in a
  ///  [Form] or [CoapConfig] passed to the [_CoapRequest].
  static final defaultCoapConfig = CoapConfigDefault();

  /// Creates a new [_CoapRequest]
  _CoapRequest(
    this._form,
    this._requestMethod, [
    this._coapConfig,
    this._subprotocol,
  ])  : _requestUri =
            _createRequestUri(_form.href, _coapConfig, defaultCoapConfig),
        _coapRequest = _requestMethod.generateRequest() {
    _coapRequest.addUriPath(_requestUri.path);
    _applyConfigParameters();
    _applyFormInformation();
    _coapClient.request = _coapRequest;
  }

  static InternetAddressType _determineAddressType(Uri uri) {
    final internetAddress = InternetAddress.tryParse(uri.host);
    if (internetAddress != null) {
      return internetAddress.type;
    } else {
      // Host is not an IP address.
      return InternetAddressType.any;
    }
  }

  static coap.CoapClient _getCoapClient(Uri uri) {
    return coap.CoapClient(uri, defaultCoapConfig)
      ..addressType = _determineAddressType(uri);
  }

  Future<coap.CoapResponse> _makeRequest(String? payload,
      [int format = coap.CoapMediaType.textPlain]) async {
    switch (_requestMethod) {
      case CoapRequestMethod.get:
        return await _coapClient.get();
      case CoapRequestMethod.post:
        // TODO(JKRhb): Decide how payloads should be handled
        payload ??= "";
        return await _coapClient.post(payload, format);
      case CoapRequestMethod.put:
        payload ??= "";
        return await _coapClient.put(payload, format);
      case CoapRequestMethod.delete:
        return await _coapClient.delete();
      default:
        throw UnimplementedError();
    }
  }

  // TODO(JKRhb): Revisit name of this method
  Future<Content> resolveInteraction(String? payload) async {
    // TODO(JKRhb): Submit PR to change return type of parse to int instead of
    //              int?
    final requestContentType = coap.CoapMediaType.parse(_form.contentType);
    final response = await _makeRequest(payload, requestContentType!);
    final responseContentType =
        response.contentFormat ?? coap.CoapMediaType.undefined;
    final type = coap.CoapMediaType.name(responseContentType);
    final body = _getPayloadFromResponse(response);
    return Content(type, body);
  }

  Future<_CoapSubscription> startObservation(
      void Function(Content content) next,
      void Function() deregisterObservation) async {
    void handleResponse(coap.CoapResponse? response) {
      if (response == null) {
        return;
      }

      final responseContentType =
          response.contentFormat ?? coap.CoapMediaType.undefined;
      final type = coap.CoapMediaType.name(responseContentType);
      final body = _getPayloadFromResponse(response);
      final content = Content(type, body);
      next(content);
    }

    if (_subprotocol == _Subprotocol.observe) {
      _coapRequest.markObserve();
      _coapRequest.responses.listen(handleResponse);
    }

    final requestContentType = coap.CoapMediaType.parse(_form.contentType);
    await _makeRequest(null, requestContentType!);
    return _CoapSubscription(_coapClient, deregisterObservation);
  }

  /// Aborts the request and closes the client.
  ///
  // TODO(JKRhb): Check if this is actually enough
  void abort() {
    _coapClient.close();
  }

  void _applyConfigParameters() {
    final coapConfig = _coapConfig;
    if (coapConfig == null) {
      return;
    }

    final blocksize = coapConfig.blocksize;
    if (blocksize != null) {
      _coapClient.useEarlyNegotiation(blocksize);
    }
  }

  static Uri _createRequestUri(
      String href, CoapConfig? coapConfig, CoapConfigDefault defaultConfig) {
    Uri uri = Uri.parse(href);

    if (uri.port == 0) {
      final int port = coapConfig?.port ?? defaultConfig.defaultPort;
      uri = uri.replace(port: port);
    }

    return uri;
  }

  void _applyFormInformation() {
    if (_form.contentType != null) {
      _coapRequest.accept = coap.CoapMediaType.parse(_form.contentType);
    } else {
      // TODO(JKRhb): Should a default accept option be set?
      _coapRequest.accept = coap.CoapMediaType.applicationJson;
    }
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
    final request = _CoapRequest(form, requestMethod, _coapConfig, subprotocol);
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
  bool setSecurity(List<SecurityScheme> metaData, Credentials? credentials) {
    // TODO(JKRhb): Add implementation for CoAPS
    return true;
  }

  @override
  Future<Subscription> subscribeResource(
      Form form,
      void Function() deregisterObservation,
      void Function(Content content) next,
      void Function(Exception error)? error,
      void Function()? complete) async {
    OperationType operationType;
    final op = form.op ?? ["observeproperty"];
    // TODO(JKRhb): Create separate function for this.
    if (op.contains("subscribeevent")) {
      operationType = OperationType.subscribeevent;
    } else {
      operationType = OperationType.observeproperty;
    }

    final request = _createRequest(form, operationType);

    return await request.startObservation(next, deregisterObservation);
  }

  @override
  Future<void> start() async {
    // Do nothing
    // TODO(JKRhb): Check if this enough.
  }

  @override
  Future<void> stop() async {
    for (final request in _pendingRequests) {
      request.abort();
    }
    _pendingRequests.clear();
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

  if (form.additionalFields["subprotocol"] == "cov:observe") {
    return _Subprotocol.observe;
  }

  return null;
}

CoapRequestMethod _requestMethodFromOperationType(OperationType operationType) {
  // TODO(JKRhb): Handle observe/subscribe case
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
      return CoapRequestMethod.get;
    case OperationType.unobserveproperty:
      return CoapRequestMethod.get;
    case OperationType.subscribeevent:
      return CoapRequestMethod.get;
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
  final dynamic formDefinition = form.additionalFields["cov:methodName"];
  if (formDefinition is String) {
    final requestMethod = _requestMethodFromString(formDefinition);
    if (requestMethod != null) {
      return requestMethod;
    }
  }

  return _requestMethodFromOperationType(operationType);
}

class _CoapSubscription implements Subscription {
  final coap.CoapClient coapClient;

  bool _active;

  @override
  bool get active => _active;

  /// Callback used to pass by the servient that is used to signal it that an
  /// observation has been cancelled.
  final void Function() _deregisterObservation;

  _CoapSubscription(this.coapClient, this._deregisterObservation)
      : _active = true;

  @override
  Future<void> stop([InteractionOptions? options]) async {
    // TODO(JKRhb): According to RFC 7641, observations can be cancelled by
    //              simply ignoring all following messages. We should evaluate
    //              whether it makes sense to explicitly cancel them instead.
    //              For now, this seems to be difficult to realize in the CoAP
    //              library implementation which is why I decided to use this
    //              approach instead for the time being.
    coapClient.close();
    _active = false;
    _deregisterObservation();
  }
}
