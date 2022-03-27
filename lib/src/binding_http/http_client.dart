// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:convert';

import 'package:http/http.dart';
import 'package:http_auth/http_auth.dart';

import '../core/content.dart';
import '../core/operation_type.dart';
import '../core/protocol_interfaces/protocol_client.dart';
import '../definitions/credentials/basic_credentials.dart';
import '../definitions/credentials/bearer_credentials.dart';
import '../definitions/credentials/credentials.dart';
import '../definitions/credentials/digest_credentials.dart';
import '../definitions/form.dart';
import '../scripting_api/subscription.dart';

const _authorizationHeader = "Authorization";

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

/// Signature of Dart's method used for HTTP GET requests.
///
/// Does not have a `body` or `encoding` parameter, in contrast to
/// [_OtherHttpMethod].
typedef _GetMethod = Future<Response> Function(Uri uri,
    {Map<String, String> headers});

/// Signature of Dart's methods used for HTTP POST, DELETE, PATCH, or PUT
/// requests.
typedef _OtherHttpMethod = Future<Response> Function(Uri uri,
    {Map<String, String>? headers, Object? body, Encoding? encoding});

/// A [ProtocolClient] for the Hypertext Transfer Protocol (HTTP).
///
/// Supports both HTTP and HTTPS as well as the Basic ([RFC 7617]),
/// Digest ([RFC 7616]), and Bearer Token ([RFC 6750]) Security Schemes.
///
/// At most one of the aforementioned Security Schemes should be defined for
/// any [Form] (as there is only one possible value for the `Authorization`
/// header that is used for these Security Schemes).  If multiple Schemes are
/// defined in a [Form], then Bearer > Digest > Basic is followed as an order of
/// priority. The definition of multiple Security Schemes will be reworked in
/// the feature using the newly introduced [`ComboSecurityScheme`], which is
/// currently still at risk.
///
/// The use of Proxies is not supported yet.
///
/// [RFC 7617]: https://datatracker.ietf.org/doc/html/rfc7617
/// [RFC 7616]: https://datatracker.ietf.org/doc/html/rfc7616
/// [RFC 6750]: https://datatracker.ietf.org/doc/html/rfc6750
/// [`ComboSecurityScheme`]: https://w3c.github.io/wot-thing-description/#combosecurityscheme
class HttpClient extends ProtocolClient {
  /// Creates a new [HttpClient].
  HttpClient();

  Future<Response> _createRequest(
      Form form, OperationType operationType, Object? payload) async {
    final requestMethod = _getRequestMethod(form, operationType);

    final Future<Response> response;
    final Uri uri = Uri.parse(form.href);
    final headers = _getHeadersFromForm(form);
    _applySecurityToHeader(form, headers);
    final BasicCredentials? basicCredentials =
        _credentialsFromForm<BasicCredentials>(form);
    final DigestCredentials? digestCredentials =
        _credentialsFromForm<DigestCredentials>(form);
    switch (requestMethod) {
      case HttpRequestMethod.get:
        final getMethod =
            _determineGetMethod(headers, digestCredentials, basicCredentials);
        response = getMethod(uri, headers: headers);
        break;
      case HttpRequestMethod.post:
        final postMethod = _determineHttpMethod(
            headers, requestMethod, digestCredentials, basicCredentials);
        response = postMethod(uri, headers: headers, body: payload);
        break;
      case HttpRequestMethod.delete:
        final deleteMethod = _determineHttpMethod(
            headers, requestMethod, digestCredentials, basicCredentials);
        response = deleteMethod(uri, headers: headers, body: payload);
        break;
      case HttpRequestMethod.put:
        final putMethod = _determineHttpMethod(
            headers, requestMethod, digestCredentials, basicCredentials);
        response = putMethod(uri, headers: headers, body: payload);
        break;
      case HttpRequestMethod.patch:
        final patchMethod = _determineHttpMethod(
            headers, requestMethod, digestCredentials, basicCredentials);
        response = patchMethod(uri, headers: headers, body: payload);
        break;
    }
    return response;
  }

  /// Selects the first instance of defined [Credentials] from a [form].
  static T? _credentialsFromForm<T extends Credentials>(Form form) {
    final credentials = form.credentials.whereType<T>();
    if (credentials.isNotEmpty) {
      return credentials.first;
    }

    return null;
  }

  static Map<String, String> _getHeadersFromForm(Form form) {
    final Map<String, String> headers = {"Content-Type": form.contentType};

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

    return headers;
  }

  Future<String> _getInputFromContent(Content content) async {
    final inputBuffer = await content.byteBuffer;
    return utf8.decoder
        .convert(inputBuffer.asUint8List().toList(growable: false));
  }

  static Content _contentFromResponse(Form form, Response response) {
    final type = response.headers["Content-Type"] ?? form.contentType;
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
    // TODO(JKRhb): implement subscribeResource
    throw UnimplementedError();
  }

  void _applySecurityToHeader(Form form, Map<String, String> headers) {
    final BearerCredentials? bearerCredentials =
        _credentialsFromForm<BearerCredentials>(form);

    if (bearerCredentials != null) {
      headers[_authorizationHeader] = "Bearer ${bearerCredentials.token}";
    }
  }

  static _GetMethod _determineGetMethod(
      Map<String, String> headers,
      DigestCredentials? digestCredentials,
      BasicCredentials? basicCredentials) {
    if (headers.containsKey(_authorizationHeader)) {
      // Bearer Security has already been defined. Therefore, we use the get
      // method of a "regular"  HTTP client.
      return get;
    }

    if (digestCredentials != null) {
      return DigestAuthClient(
              digestCredentials.username, digestCredentials.password)
          .get;
    } else if (basicCredentials != null) {
      return BasicAuthClient(
              basicCredentials.username, basicCredentials.password)
          .get;
    } else {
      return get;
    }
  }

  static _OtherHttpMethod _determineHttpMethod(
      Map<String, String> headers,
      HttpRequestMethod requestMethod,
      DigestCredentials? digestCredentials,
      BasicCredentials? basicCredentials) {
    DigestAuthClient? digestClient;
    BasicAuthClient? basicClient;

    if (!headers.containsKey(_authorizationHeader)) {
      // Bearer Security has not been defined, yet. Therefore, we determine if
      // we should use an HTTP client for Digest or Basic Authentication.
      if (digestCredentials != null) {
        digestClient = DigestAuthClient(
            digestCredentials.username, digestCredentials.password);
      } else if (basicCredentials != null) {
        basicClient = BasicAuthClient(
            basicCredentials.username, basicCredentials.password);
      }
    }

    switch (requestMethod) {
      case HttpRequestMethod.post:
        return digestClient?.post ?? basicClient?.post ?? post;
      case HttpRequestMethod.delete:
        return digestClient?.delete ?? basicClient?.delete ?? delete;
      case HttpRequestMethod.patch:
        return digestClient?.patch ?? basicClient?.patch ?? patch;
      case HttpRequestMethod.put:
        return digestClient?.put ?? basicClient?.put ?? put;
      default:
        throw ArgumentError("Invalid HTTP method specified.");
    }
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
