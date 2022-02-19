// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/content.dart';
import '../core/operation_type.dart';
import '../core/protocol_interfaces/protocol_client.dart';
import '../definitions/credentials/basic_credentials.dart';
import '../definitions/form.dart';
import '../definitions/security/basic_security_scheme.dart';
import '../scripting_api/subscription.dart';
import 'http_config.dart';

/// Defines the available HTTP request methods.
enum HttpRequestMethod {
  /// Corresponds with the GET request method.
  get,

  /// Corresponds with the PUT request method.
  put,

  /// Corresponds with the POST request method.
  post,

  /// Corresponds with the DELETE request method.
  delete,

  /// Corresponds with the PATCH request method.
  patch,
}

/// A [ProtocolClient] for the Hypertext Transfer Protocol (HTTP).
class HttpClient extends ProtocolClient {
  /// An (optional) custom [HttpConfig] which overrides the default values.
  final HttpConfig? _httpConfig;

  /// Creates a new [HttpClient] based on an optional [HttpConfig].
  HttpClient([this._httpConfig]);

  Future<http.Response> _createRequest(
      Form form, OperationType operationType, Object? payload) async {
    final requestMethod = _getRequestMethod(form, operationType);

    final Future<http.Response> response;
    final Uri uri = Uri.parse(form.href);
    final headers = _getHeadersFromForm(form);
    _applySecurityToHeader(form, headers);
    switch (requestMethod) {
      case HttpRequestMethod.get:
        response = http.get(uri, headers: headers);
        break;
      case HttpRequestMethod.post:
        response = http.post(uri, headers: headers, body: payload);
        break;
      case HttpRequestMethod.delete:
        response = http.delete(uri, headers: headers, body: payload);
        break;
      case HttpRequestMethod.put:
        response = http.put(uri, headers: headers, body: payload);
        break;
      case HttpRequestMethod.patch:
        response = http.patch(uri, headers: headers, body: payload);
        break;
    }
    return response;
  }

  static Map<String, String> _getHeadersFromForm(Form form) {
    final Map<String, String> headers = {};

    final dynamic formHeaders = form.additionalFields["htv:headers"];
    if (formHeaders is List<Map<String, String>>) {
      for (final formHeader in formHeaders) {
        final key = formHeader["htv:fieldName"];
        final value = formHeader["htv:fieldValue"];

        if (key != null && value != null) {
          headers[key] = value;
        }
      }
    }

    final contentType = form.contentType;
    if (contentType != null) {
      headers["Content-Type"] = contentType;
    }

    return headers;
  }

  Future<String> _getInputFromContent(Content content) async {
    final inputBuffer = await content.byteBuffer;
    return utf8.decoder
        .convert(inputBuffer.asUint8List().toList(growable: false));
  }

  static Content _contentFromResponse(Form form, http.Response response) {
    final type = response.headers["Content-Type"] ??
        form.contentType ??
        "application/octet-stream";
    final body = Stream.value(response.bodyBytes);
    return Content(type, body);
  }

  @override
  Future<Content> invokeResource(Form form, Content content) async {
    final input = await _getInputFromContent(content);
    final response =
        await _createRequest(form, OperationType.invokeaction, input);
    return _contentFromResponse(form, response);
  }

  @override
  Future<Content> readResource(Form form) async {
    final response =
        await _createRequest(form, OperationType.readproperty, null);
    return _contentFromResponse(form, response);
  }

  @override
  Future<void> start() async {
    // Do nothing
  }

  @override
  Future<void> stop() async {
    // Do nothing
  }

  @override
  Future<void> writeResource(Form form, Content content) async {
    final input = await _getInputFromContent(content);
    await _createRequest(form, OperationType.writeproperty, input);
  }

  @override
  Future<Subscription> subscribeResource(Form form,
      {required void Function(Content content) next,
      void Function(Exception error)? error,
      required void Function() complete}) async {
    // TODO: implement subscribeResource
    throw UnimplementedError();
  }

  void _applySecurityToHeader(Form form, Map<String, String> headers) {
    final securityDefinitions = form.securityDefinitions.values.toList();
    for (final securityDefinition in securityDefinitions) {
      if (securityDefinition is BasicSecurityScheme) {
        if (securityDefinition.in_ != "header") {
          continue;
        }
        final credentials = securityDefinition.credentials;
        if (credentials is BasicCredentials) {
          _applyBasicSecurityToHeader(headers, credentials);
        }
      }
    }
  }

  static void _applyBasicSecurityToHeader(
      Map<String, String> headers, BasicCredentials credentials) {
    final username = credentials.username;
    final password = credentials.password;
    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    headers["authorization"] = basicAuth;
  }
}

HttpRequestMethod _requestMethodFromOperationType(OperationType operationType) {
  // TODO(JKRhb): Handle observe/subscribe case
  switch (operationType) {
    case OperationType.readproperty:
    case OperationType.readmultipleproperties:
    case OperationType.readallproperties:
      return HttpRequestMethod.get;
    case OperationType.writeproperty:
    case OperationType.writemultipleproperties:
      return HttpRequestMethod.put;
    case OperationType.invokeaction:
      return HttpRequestMethod.post;
    default:
      throw UnimplementedError();
  }
}

HttpRequestMethod? _requestMethodFromString(String formDefinition) {
  switch (formDefinition) {
    case "POST":
      return HttpRequestMethod.post;
    case "PUT":
      return HttpRequestMethod.put;
    case "DELETE":
      return HttpRequestMethod.delete;
    case "GET":
      return HttpRequestMethod.get;
    case "PATCH":
      return HttpRequestMethod.patch;
    default:
      return null;
  }
}

HttpRequestMethod _getRequestMethod(Form form, OperationType operationType) {
  final dynamic formDefinition = form.additionalFields["htv:methodName"];
  if (formDefinition is String) {
    final requestMethod = _requestMethodFromString(formDefinition);
    if (requestMethod != null) {
      return requestMethod;
    }
  }

  return _requestMethodFromOperationType(operationType);
}
