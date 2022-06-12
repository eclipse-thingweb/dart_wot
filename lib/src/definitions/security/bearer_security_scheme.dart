// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'helper_functions.dart';
import 'security_scheme.dart';

/// Bearer Token security configuration identified by the Vocabulary Term
/// `bearer`.
class BearerSecurityScheme extends SecurityScheme {
  /// Constructor.
  BearerSecurityScheme({
    String? description,
    String? proxy,
    this.name,
    String? alg,
    String? format,
    this.authorization,
    String? in_,
    Map<String, String>? descriptions,
  })  : in_ = in_ ?? 'header',
        alg = alg ?? 'ES256',
        format = format ?? 'jwt' {
    this.description = description;
    this.proxy = proxy;
    this.descriptions.addAll(descriptions ?? {});
  }

  /// Creates a [BearerSecurityScheme] from a [json] object.
  BearerSecurityScheme.fromJson(Map<String, dynamic> json) {
    _parsedJsonFields.addAll(parseSecurityJson(this, json));

    final dynamic jsonIn = _getJsonValue(json, 'in');
    if (jsonIn is String) {
      in_ = jsonIn;
      _parsedJsonFields.add('in');
    }

    final dynamic jsonName = _getJsonValue(json, 'name');
    if (jsonName is String) {
      name = jsonName;
      _parsedJsonFields.add('name');
    }

    final dynamic jsonFormat = _getJsonValue(json, 'format');
    if (jsonFormat is String) {
      format = jsonFormat;
      _parsedJsonFields.add('format');
    }

    final dynamic jsonAlg = _getJsonValue(json, 'alg');
    if (jsonAlg is String) {
      alg = jsonAlg;
      _parsedJsonFields.add('alg');
    }

    final dynamic jsonAuthorization = _getJsonValue(json, 'authorization');
    if (jsonAuthorization is String) {
      authorization = jsonAuthorization;
      _parsedJsonFields.add('authorization');
    }

    parseAdditionalFields(additionalFields, json, _parsedJsonFields);
  }

  @override
  String get scheme => 'bearer';

  /// URI of the authorization server.
  String? authorization;

  /// Name for query, header, cookie, or uri parameters.
  String? name;

  /// Encoding, encryption, or digest algorithm.
  String alg = 'ES256';

  /// Specifies format of security authentication information.
  String? format = 'jwt';

  /// Specifies the location of security authentication information.
  String in_ = 'header';

  final List<String> _parsedJsonFields = [];

  dynamic _getJsonValue(Map<String, dynamic> json, String key) {
    _parsedJsonFields.add(key);
    return json[key];
  }
}
