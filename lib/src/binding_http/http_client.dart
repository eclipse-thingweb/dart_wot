// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:convert';

import 'package:http/http.dart';
import 'package:http_auth/http_auth.dart';

import '../core/content.dart';
import '../core/credentials/basic_credentials.dart';
import '../core/credentials/bearer_credentials.dart';
import '../core/credentials/credentials.dart';
import '../core/credentials/digest_credentials.dart';
import '../core/discovery/core_link_format.dart';
import '../core/protocol_interfaces/protocol_client.dart';
import '../core/security_provider.dart';
import '../definitions/form.dart';
import '../definitions/operation_type.dart';
import '../definitions/security/basic_security_scheme.dart';
import '../definitions/security/bearer_security_scheme.dart';
import '../definitions/security/digest_security_scheme.dart';
import '../definitions/security/security_scheme.dart';
import '../definitions/thing_description.dart';
import '../scripting_api/subscription.dart';
import 'http_request_method.dart';

const _authorizationHeader = 'Authorization';

/// Signature of Dart's method used for HTTP GET requests.
///
/// Does not have a `body` or `encoding` parameter, in contrast to
/// [OtherHttpMethod].
typedef GetMethod = Future<Response> Function(
  Uri uri, {
  Map<String, String> headers,
});

/// Signature of Dart's methods used for HTTP POST, DELETE, PATCH, or PUT
/// requests.
typedef OtherHttpMethod = Future<Response> Function(
  Uri uri, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
});

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
  HttpClient(this._clientSecurityProvider);

  final ClientSecurityProvider? _clientSecurityProvider;

  Future<Response> _createRequest(
    Form form,
    OperationType operationType,
    Object? payload,
  ) async {
    final requestMethod =
        HttpRequestMethod.getRequestMethod(form, operationType);

    final Future<Response> response;
    final Uri uri = form.resolvedHref;
    final headers = _getHeadersFromForm(form);
    await _applySecurityToHeader(form, headers);
    final BasicCredentials? basicCredentials =
        await _getCredentialsFromForm<BasicCredentials>(form);
    final DigestCredentials? digestCredentials =
        await _getCredentialsFromForm<DigestCredentials>(form);
    switch (requestMethod) {
      case HttpRequestMethod.get:
        final getMethod =
            _determineGetMethod(headers, digestCredentials, basicCredentials);
        response = getMethod(uri, headers: headers);
        break;
      case HttpRequestMethod.post:
        final postMethod = _determineHttpMethod(
          headers,
          requestMethod,
          digestCredentials,
          basicCredentials,
        );
        response = postMethod(uri, headers: headers, body: payload);
        break;
      case HttpRequestMethod.delete:
        final deleteMethod = _determineHttpMethod(
          headers,
          requestMethod,
          digestCredentials,
          basicCredentials,
        );
        response = deleteMethod(uri, headers: headers, body: payload);
        break;
      case HttpRequestMethod.put:
        final putMethod = _determineHttpMethod(
          headers,
          requestMethod,
          digestCredentials,
          basicCredentials,
        );
        response = putMethod(uri, headers: headers, body: payload);
        break;
      case HttpRequestMethod.patch:
        final patchMethod = _determineHttpMethod(
          headers,
          requestMethod,
          digestCredentials,
          basicCredentials,
        );
        response = patchMethod(uri, headers: headers, body: payload);
        break;
    }
    return response;
  }

  static bool _hasSecurityScheme<T extends SecurityScheme>(Form form) {
    return form.securityDefinitions.whereType<T>().isNotEmpty;
  }

  static AsyncClientSecurityCallback<T>?
      _determineCallback<T extends Credentials>(
    ClientSecurityProvider securityProvider,
    Form form,
  ) {
    AsyncClientSecurityCallback<T>? callback;

    switch (T) {
      case BearerCredentials:
        if (_hasSecurityScheme<BearerSecurityScheme>(form)) {
          callback = securityProvider.bearerCredentialsCallback
              as AsyncClientSecurityCallback<T>?;
        }
        break;
      case DigestCredentials:
        if (_hasSecurityScheme<DigestSecurityScheme>(form)) {
          callback = securityProvider.digestCredentialsCallback
              as AsyncClientSecurityCallback<T>?;
        }
        break;
      case BasicCredentials:
        if (_hasSecurityScheme<BasicSecurityScheme>(form)) {
          callback = securityProvider.basicCredentialsCallback
              as AsyncClientSecurityCallback<T>?;
        }
        break;
    }

    return callback;
  }

  /// Selects the first instance of defined [Credentials] from a [form].
  Future<T?> _getCredentialsFromForm<T extends Credentials>(Form form) async {
    final securityProvider = _clientSecurityProvider;

    if (securityProvider == null) {
      return null;
    }

    final callback = _determineCallback<T>(securityProvider, form);

    if (callback == null) {
      return null;
    }

    return callback(form.resolvedHref, form);
  }

  static Map<String, String> _getHeadersFromForm(Form form) {
    final Map<String, String> headers = {'Content-Type': form.contentType};

    final dynamic formHeaders = form.additionalFields['htv:headers'];
    if (formHeaders is List<Map<String, String>>) {
      for (final formHeader in formHeaders) {
        final key = formHeader['htv:fieldName'];
        final value = formHeader['htv:fieldValue'];

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
    final type = response.headers['Content-Type'] ?? form.contentType;
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
  Future<Subscription> subscribeResource(
    Form form, {
    required void Function(Content content) next,
    void Function(Exception error)? error,
    required void Function() complete,
  }) async {
    // TODO(JKRhb): implement subscribeResource
    throw UnimplementedError();
  }

  Future<void> _applySecurityToHeader(
    Form form,
    Map<String, String> headers,
  ) async {
    final BearerCredentials? bearerCredentials =
        await _getCredentialsFromForm<BearerCredentials>(form);

    if (bearerCredentials != null) {
      headers[_authorizationHeader] = 'Bearer ${bearerCredentials.token}';
    }
  }

  static GetMethod _determineGetMethod(
    Map<String, String> headers,
    DigestCredentials? digestCredentials,
    BasicCredentials? basicCredentials,
  ) {
    if (headers.containsKey(_authorizationHeader)) {
      // Bearer Security has already been defined. Therefore, we use the get
      // method of a "regular"  HTTP client.
      return get;
    }

    if (digestCredentials != null) {
      return DigestAuthClient(
        digestCredentials.username,
        digestCredentials.password,
      ).get;
    } else if (basicCredentials != null) {
      return BasicAuthClient(
        basicCredentials.username,
        basicCredentials.password,
      ).get;
    } else {
      return get;
    }
  }

  static OtherHttpMethod _determineHttpMethod(
    Map<String, String> headers,
    HttpRequestMethod requestMethod,
    DigestCredentials? digestCredentials,
    BasicCredentials? basicCredentials,
  ) {
    DigestAuthClient? digestClient;
    BasicAuthClient? basicClient;

    if (!headers.containsKey(_authorizationHeader)) {
      // Bearer Security has not been defined, yet. Therefore, we determine if
      // we should use an HTTP client for Digest or Basic Authentication.
      if (digestCredentials != null) {
        digestClient = DigestAuthClient(
          digestCredentials.username,
          digestCredentials.password,
        );
      } else if (basicCredentials != null) {
        basicClient = BasicAuthClient(
          basicCredentials.username,
          basicCredentials.password,
        );
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
        throw ArgumentError('Invalid HTTP method specified.');
    }
  }

  @override
  // TODO(JKRhb): Support Security Bootstrapping as described in
  //              https://github.com/w3c/wot-discovery/pull/313/files
  Stream<ThingDescription> discoverDirectly(
    Uri uri, {
    bool disableMulticast = false,
  }) async* {
    final response = await get(uri, headers: {'Accept': 'application/td+json'});
    final rawThingDescription = response.body;
    yield ThingDescription(rawThingDescription);
  }

  @override
  Stream<Uri> discoverWithCoreLinkFormat(Uri uri) async* {
    // TODO(JKRhb): Support Security Bootstrapping as described in
    //              https://github.com/w3c/wot-discovery/pull/313/files
    final discoveryUri = createCoreLinkFormatDiscoveryUri(uri);

    final response =
        await get(discoveryUri, headers: {'Accept': 'application/link-format'});

    yield* Stream.fromIterable(
      parseCoreLinkFormat(response.body, discoveryUri),
    );
  }
}
