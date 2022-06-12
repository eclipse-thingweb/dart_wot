// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'helper_functions.dart';
import 'security_scheme.dart';

/// Pre-shared key authentication security configuration identified by the
/// Vocabulary Term `psk`.
class PskSecurityScheme extends SecurityScheme {
  /// Constructor.
  PskSecurityScheme(
      {this.identity,
      String? description,
      String? proxy,
      Map<String, String>? descriptions}) {
    this.description = description;
    this.proxy = proxy;
    this.descriptions.addAll(descriptions ?? {});
  }

  /// Creates a [PskSecurityScheme] from a [json] object.
  PskSecurityScheme.fromJson(Map<String, dynamic> json) {
    _parsedJsonFields.addAll(parseSecurityJson(this, json));

    final dynamic jsonIdentity = _getJsonValue(json, 'identity');
    if (jsonIdentity is String) {
      identity = jsonIdentity;
      _parsedJsonFields.add('identity');
    }

    parseAdditionalFields(additionalFields, json, _parsedJsonFields);
  }

  @override
  String get scheme => 'psk';

  /// Name for query, header, cookie, or uri parameters.
  String? identity;

  final List<String> _parsedJsonFields = [];

  dynamic _getJsonValue(Map<String, dynamic> json, String key) {
    _parsedJsonFields.add(key);
    return json[key];
  }
}
