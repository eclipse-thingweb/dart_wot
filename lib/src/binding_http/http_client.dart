// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:convert";
import "dart:io";
import "dart:io" as io;

import "package:http/http.dart";
import "package:http/io_client.dart";

import "../../core.dart";

import "http_config.dart";
import "http_request_method.dart";
import "http_security_exception.dart";

const _authorizationHeader = "Authorization";

/// A [ProtocolClient] for the Hypertext Transfer Protocol (HTTP).
///
/// Supports both HTTP and HTTPS as well as the Basic ([RFC 7617]) and Bearer
/// Token ([RFC 6750]) Security Schemes.
///
/// At most one of the aforementioned Security Schemes should be defined for
/// any [Form] (as there is only one possible value for the `Authorization`
/// header that is used for these Security Schemes).  If multiple Schemes are
/// defined in a [Form], then Bearer > Basic is followed as an order of
/// priority. The definition of multiple Security Schemes will be reworked in
/// the feature using the newly introduced [`ComboSecurityScheme`], which is
/// currently still at risk.
///
/// The use of Proxies is not supported yet, while support for the digest
/// security scheme has been temporarily removed.
/// Additional trusted certificates can be added via an (optional)
/// [HttpClientConfig].
///
/// [RFC 7617]: https://datatracker.ietf.org/doc/html/rfc7617
/// [RFC 7616]: https://datatracker.ietf.org/doc/html/rfc7616
/// [RFC 6750]: https://datatracker.ietf.org/doc/html/rfc6750
/// [`ComboSecurityScheme`]: https://w3c.github.io/wot-thing-description/#combosecurityscheme
final class HttpClient extends ProtocolClient
    with DirectDiscoverer, CoreLinkFormatDiscoverer {
  /// Creates a new [HttpClient].
  HttpClient({
    HttpClientConfig? httpClientConfig,
    AsyncClientSecurityCallback<BasicCredentials>? basicCredentialsCallback,
    AsyncClientSecurityCallback<BearerCredentials>? bearerCredentialsCallback,
  })  : _basicCredentialsCallback = basicCredentialsCallback,
        _bearerCredentialsCallback = bearerCredentialsCallback,
        _client =
            IOClient(io.HttpClient(context: _createContext(httpClientConfig)));

  static SecurityContext _createContext(HttpClientConfig? httpClientConfig) {
    final context = SecurityContext();

    final trustedCertificates = httpClientConfig?.trustedCertificates ?? [];

    for (final trustedCertificate in trustedCertificates) {
      context.setTrustedCertificatesBytes(
        trustedCertificate.certificate,
        password: trustedCertificate.password,
      );
    }

    return context;
  }

  final IOClient _client;

  final AsyncClientSecurityCallback<BasicCredentials>?
      _basicCredentialsCallback;

  final AsyncClientSecurityCallback<BearerCredentials>?
      _bearerCredentialsCallback;

  Future<void> _applyCredentialsFromForm(
    Request request,
    AugmentedForm form,
  ) async {
    // TODO(JKRhb): Add DigestSecurity back in
    if (await _applyBearerCredentialsFromForm(request, form)) {
      return;
    }

    if (await _applyBasicCredentialsFromForm(request, form)) {
      return;
    }
  }

  Future<bool> _applyBasicCredentialsFromForm(
    Request request,
    AugmentedForm form,
  ) async {
    final basicSecuritySchemes =
        form.securityDefinitions.whereType<BasicSecurityScheme>();

    if (basicSecuritySchemes.isEmpty) {
      return false;
    }

    final basicCredentials =
        await _getBasicCredentials(form.resolvedHref, form);

    if (basicCredentials == null) {
      return false;
    }

    _applyBasicCredentials(basicCredentials, request);

    return true;
  }

  Future<bool> _applyBearerCredentialsFromForm(
    Request request,
    AugmentedForm form,
  ) async {
    final bearerSecuritySchemes =
        form.securityDefinitions.whereType<BearerSecurityScheme>();

    if (bearerSecuritySchemes.isEmpty) {
      return false;
    }

    final bearerCredentials =
        await _getBearerCredentials(form.resolvedHref, form);

    if (bearerCredentials == null) {
      return false;
    }

    _applyBearerCredentials(bearerCredentials, request);

    return true;
  }

  void _applyBasicCredentials(BasicCredentials credentials, Request request) {
    final username = credentials.username;
    final password = credentials.password;

    final bytes = utf8.encode("$username:$password");
    final base64Credentials = base64.encode(bytes);
    request.headers[_authorizationHeader] = "Basic $base64Credentials";
  }

  void _applyBearerCredentials(
    BearerCredentials credentials,
    Request request,
  ) {
    request.headers[_authorizationHeader] = "Bearer ${credentials.token}";
  }

  Request _copyRequest(Request request) {
    return Request(request.method, request.url)
      ..body = request.body
      ..headers.addAll(request.headers);
  }

  Future<StreamedResponse> _createBasicAuthRequest(
    Request originalRequest,
    AugmentedForm? form,
  ) async {
    final request = _copyRequest(originalRequest);
    final basicCredentials = await _getBasicCredentials(request.url, form);

    if (basicCredentials == null) {
      throw HttpSecurityException("No BasicCredentials have been provided.");
    }

    _applyBasicCredentials(basicCredentials, request);

    return _client.send(request);
  }

  Future<StreamedResponse> _createBearerAuthRequest(
    Request originalRequest,
    AugmentedForm? form,
  ) async {
    final request = _copyRequest(originalRequest);
    final bearerCredentials = await _getBearerCredentials(request.url, form);

    if (bearerCredentials == null) {
      throw HttpSecurityException("No BearerCredentials have been provided.");
    }

    _applyBearerCredentials(bearerCredentials, request);

    return _client.send(request);
  }

  Future<StreamedResponse> _handleResponse(
    Request originalRequest,
    StreamedResponse response, [
    AugmentedForm? form,
  ]) async {
    if (response.statusCode == HttpStatus.unauthorized) {
      final authenticate = response.headers["www-authenticate"];

      if (authenticate != null) {
        final method = authenticate.split(" ")[0];
        switch (method) {
          case "Basic":
            return _createBasicAuthRequest(originalRequest, form);
          case "Bearer":
            return _createBearerAuthRequest(originalRequest, form);
        }
      }
    }

    return response;
  }

  Future<StreamedResponse> _createRequest(
    AugmentedForm form,
    OperationType operationType,
    Content? content,
  ) async {
    final requestMethod =
        HttpRequestMethod.getRequestMethod(form, operationType);
    final Uri uri = form.resolvedHref;

    final request = Request(requestMethod.methodName, uri)
      ..headers.addAll(_getHeadersFromForm(form))
      ..bodyBytes = await content?.toByteList() ?? [];

    await _applyCredentialsFromForm(request, form);

    final response = await _client.send(request);

    return _handleResponse(request, response, form);
  }

  Future<BasicCredentials?> _getBasicCredentials(
    Uri uri,
    AugmentedForm? form, [
    BasicCredentials? invalidCredentials,
  ]) async {
    return _basicCredentialsCallback?.call(uri, form, invalidCredentials);
  }

  Future<BearerCredentials?> _getBearerCredentials(
    Uri uri,
    AugmentedForm? form, [
    BearerCredentials? invalidCredentials,
  ]) async {
    return _bearerCredentialsCallback?.call(uri, form, invalidCredentials);
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

  Content _contentFromResponse(Form form, StreamedResponse response) {
    final type = response.headers["Content-Type"] ?? form.contentType;
    final responseStream = response.stream.asBroadcastStream()
      ..listen(null, onDone: stop);
    return Content(type, responseStream);
  }

  @override
  Future<Content> invokeResource(AugmentedForm form, Content content) async {
    final response =
        await _createRequest(form, OperationType.invokeaction, content);
    return _contentFromResponse(form, response);
  }

  @override
  Future<Content> readResource(AugmentedForm form) async {
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
    _client.close();
  }

  @override
  Future<void> writeResource(AugmentedForm form, Content content) async {
    await _createRequest(form, OperationType.writeproperty, content);
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

  Future<DiscoveryContent> _sendDiscoveryRequest(
    Request request, {
    required String acceptHeaderValue,
  }) async {
    request.headers["Accept"] = acceptHeaderValue;
    final response = await _client.send(request);
    final finalResponse = await _handleResponse(request, response);
    return DiscoveryContent(
      response.headers["Content-Type"] ?? acceptHeaderValue,
      finalResponse.stream,
      request.url,
    );
  }

  @override
  Future<DiscoveryContent> discoverDirectly(
    Uri uri, {
    bool disableMulticast = false,
  }) async {
    final request = Request(HttpRequestMethod.get.methodName, uri);

    return _sendDiscoveryRequest(
      request,
      acceptHeaderValue: "application/td+json",
    );
  }

  @override
  Stream<DiscoveryContent> discoverWithCoreLinkFormat(Uri uri) async* {
    final request = Request(HttpRequestMethod.get.methodName, uri);

    final encodedLinks = await _sendDiscoveryRequest(
      request,
      acceptHeaderValue: "application/link-format",
    );

    yield encodedLinks;
  }
}
