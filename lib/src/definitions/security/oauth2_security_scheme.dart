// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../validation/validation_exception.dart';
import 'helper_functions.dart';
import 'security_scheme.dart';

/// OAuth 2.0 authentication security configuration for systems conformant with
/// RFC 6749, RFC 8252 and (for the device flow) RFC 8628, identified by the
/// Vocabulary Term `oauth2`.
class OAuth2SecurityScheme extends SecurityScheme {
  /// Constructor.
  OAuth2SecurityScheme(
    this.flow, {
    String? description,
    this.authorization,
    this.scopes,
    this.refresh,
    this.token,
    Map<String, String>? descriptions,
  }) {
    this.description = description;
    this.descriptions.addAll(descriptions ?? {});
  }

  /// Creates a [OAuth2SecurityScheme] from a [json] object.
  OAuth2SecurityScheme.fromJson(Map<String, dynamic> json) {
    _parsedJsonFields.addAll(parseSecurityJson(this, json));

    final dynamic jsonAuthorization = _getJsonValue(json, 'authorization');
    if (jsonAuthorization is String) {
      authorization = jsonAuthorization;
      _parsedJsonFields.add('authorization');
    }

    final dynamic jsonToken = _getJsonValue(json, 'token');
    if (jsonToken is String) {
      token = jsonToken;
      _parsedJsonFields.add('token');
    }

    final dynamic jsonRefresh = _getJsonValue(json, 'refresh');
    if (jsonRefresh is String) {
      refresh = jsonRefresh;
      _parsedJsonFields.add('refresh');
    }

    final dynamic jsonScopes = _getJsonValue(json, 'scopes');
    if (jsonScopes is String) {
      scopes = [jsonScopes];
      _parsedJsonFields.add('scopes');
    } else if (jsonScopes is List<dynamic>) {
      scopes = jsonScopes.whereType<String>().toList(growable: false);
      _parsedJsonFields.add('scopes');
    }

    final dynamic jsonFlow = _getJsonValue(json, 'flow');
    if (jsonFlow is String) {
      flow = jsonFlow;
      _parsedJsonFields.add('flow');
    } else {
      throw ValidationException("flow must be of type 'string'!");
    }

    parseAdditionalFields(additionalFields, json, _parsedJsonFields);
  }
  @override
  String get scheme => 'oauth2';

  /// URI of the authorization server.
  ///
  /// In the case of the `device` flow, the URI provided for the [authorization]
  /// value refers to the device authorization endpoint.
  String? authorization;

  /// URI of the token server.
  String? token;

  /// URI of the authorization server.
  String? refresh;

  /// Set of authorization scope identifiers provided as an array.
  ///
  /// These are provided in tokens returned by an authorization server and
  /// associated with forms in order to identify what resources a client may
  /// access and how. The values associated with a form should be chosen from
  /// those defined in an [OAuth2SecurityScheme] active on that form.
  List<String>? scopes;

  /// Authorization flow.
  late String flow;

  final List<String> _parsedJsonFields = [];

  dynamic _getJsonValue(Map<String, dynamic> json, String key) {
    _parsedJsonFields.add(key);
    return json[key];
  }
}
