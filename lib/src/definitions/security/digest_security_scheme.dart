// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'helper_functions.dart';
import 'security_scheme.dart';

/// Digest Access Authentication security configuration identified by the
/// Vocabulary Term `digest`.
class DigestSecurityScheme extends SecurityScheme {
  @override
  String get scheme => "digest";

  /// Name for query, header, cookie, or uri parameters.
  String? name;

  /// Specifies the location of security authentication information.
  late String in_ = "header";

  /// Quality of protection.
  late String qop = "auth";

  final List<String> _parsedJsonFields = [];

  /// Constructor.
  DigestSecurityScheme(
      {String? description,
      String? proxy,
      this.name,
      String? in_,
      String? qop,
      Map<String, String>? descriptions})
      : in_ = in_ ?? "header",
        qop = qop ?? "auth" {
    this.description = description;
    this.descriptions.addAll(descriptions ?? {});
  }

  dynamic _getJsonValue(Map<String, dynamic> json, String key) {
    _parsedJsonFields.add(key);
    return json[key];
  }

  /// Creates a [DigestSecurityScheme] from a [json] object.
  DigestSecurityScheme.fromJson(Map<String, dynamic> json) {
    _parsedJsonFields.addAll(parseSecurityJson(this, json));

    final dynamic jsonIn = _getJsonValue(json, "in");
    if (jsonIn is String) {
      in_ = jsonIn;
      _parsedJsonFields.add("in");
    }

    final dynamic jsonQop = _getJsonValue(json, "qop");
    if (jsonQop is String) {
      qop = jsonQop;
      _parsedJsonFields.add("qop");
    }

    final dynamic jsonName = _getJsonValue(json, "name");
    if (jsonName is String) {
      name = jsonName;
      _parsedJsonFields.add("name");
    }

    parseAdditionalFields(additionalFields, json, _parsedJsonFields);
  }
}
