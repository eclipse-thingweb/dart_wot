// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:curie/curie.dart';

import '../extensions/json_parser.dart';
import 'security_scheme.dart';

const _schemeName = 'oauth2';

/// OAuth 2.0 authentication security configuration for systems conformant with
/// RFC 6749, RFC 8252 and (for the device flow) RFC 8628, identified by the
/// Vocabulary Term `oauth2`.
class OAuth2SecurityScheme extends SecurityScheme {
  /// Constructor.
  OAuth2SecurityScheme(
    this.flow, {
    this.authorization,
    this.scopes,
    this.refresh,
    this.token,
    super.description,
    super.descriptions,
    super.proxy,
    super.jsonLdType,
    super.additionalFields,
  }) : super(_schemeName);

  /// Creates a [OAuth2SecurityScheme] from a [json] object.
  OAuth2SecurityScheme.fromJson(
    Map<String, dynamic> json,
    PrefixMapping prefixMapping,
    Set<String> parsedFields,
  )   : authorization = json.parseField<String>('authorization', parsedFields),
        token = json.parseField<String>('token', parsedFields),
        refresh = json.parseField<String>('refresh', parsedFields),
        scopes = json.parseArrayField<String>('scopes', parsedFields),
        flow = json.parseRequiredField<String>('flow', parsedFields),
        super.fromJson(_schemeName, json, prefixMapping, parsedFields);

  /// URI of the authorization server.
  ///
  /// In the case of the `device` flow, the URI provided for the [authorization]
  /// value refers to the device authorization endpoint.
  final String? authorization;

  /// URI of the token server.
  final String? token;

  /// URI of the authorization server.
  final String? refresh;

  /// Set of authorization scope identifiers provided as an array.
  ///
  /// These are provided in tokens returned by an authorization server and
  /// associated with forms in order to identify what resources a client may
  /// access and how. The values associated with a form should be chosen from
  /// those defined in an [OAuth2SecurityScheme] active on that form.
  final List<String>? scopes;

  /// Authorization flow.
  final String flow;
}
