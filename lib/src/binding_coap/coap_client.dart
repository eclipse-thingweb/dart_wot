// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import 'dart:convert';
import 'dart:io';

import 'package:coap/coap.dart' as coap;
import 'package:coap/config/coap_config_default.dart';

import '../core/content.dart';
import '../core/credentials.dart';
import '../core/operation_type.dart';
import '../core/protocol_interfaces/protocol_client.dart';
import '../core/subscription.dart';
import '../definitions/form.dart';
import '../definitions/security_scheme.dart';
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

  /// This [defaultCoapConfig] is used if parameters should not be set in a
  ///  [Form] or [CoapConfig] passed to the [_CoapRequest].
  static final defaultCoapConfig = CoapConfigDefault();

  /// Creates a new [_CoapRequest]
  _CoapRequest(this._form, this._requestMethod, [this._coapConfig])
      : _requestUri =
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
    final request = _CoapRequest(form, requestMethod, _coapConfig);
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
    return;
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
      void Function(Content content) next,
      void Function(Exception error)? error,
      void Function()? complete) {
    // TODO(JKRhb): implement subscribeResource
    throw UnimplementedError();
  }

  @override
  Future<Content> unsubscribeResource(Form form) {
    // TODO(JKRhb): implement unsubscribeResource
    throw UnimplementedError();
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

CoapRequestMethod _requestMethodFromOperationType(OperationType operationType) {
  // TODO(JKRhb): Handle observe/subscribe case
  switch (operationType) {
    case OperationType.readproperty:
      return CoapRequestMethod.get;
    case OperationType.writeproperty:
      return CoapRequestMethod.put;
    case OperationType.invokeaction:
      return CoapRequestMethod.post;
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
