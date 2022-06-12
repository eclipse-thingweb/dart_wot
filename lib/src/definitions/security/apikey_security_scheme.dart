// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'helper_functions.dart';
import 'security_scheme.dart';

/// API key authentication security configuration identified by the Vocabulary
/// Term `apikey`.
class ApiKeySecurityScheme extends SecurityScheme {
  /// Constructor.
  ApiKeySecurityScheme(
      {String? description,
      String? proxy,
      this.name,
      String? in_,
      Map<String, String>? descriptions})
      : in_ = in_ ?? 'query' {
    this.description = description;
    this.proxy = proxy;
    this.descriptions.addAll(descriptions ?? {});
  }

  /// Creates a [ApiKeySecurityScheme] from a [json] object.
  ApiKeySecurityScheme.fromJson(Map<String, dynamic> json) {
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

    parseAdditionalFields(additionalFields, json, _parsedJsonFields);
  }

  @override
  String get scheme => 'apikey';

  /// Name for query, header, cookie, or uri parameters.
  String? name;

  /// Specifies the location of security authentication information.
  late String in_ = 'query';

  final List<String> _parsedJsonFields = [];

  dynamic _getJsonValue(Map<String, dynamic> json, String key) {
    _parsedJsonFields.add(key);
    return json[key];
  }
}
