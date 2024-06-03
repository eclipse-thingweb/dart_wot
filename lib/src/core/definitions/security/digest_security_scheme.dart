// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:curie/curie.dart";

import "../extensions/json_parser.dart";
import "security_scheme.dart";

/// Indicates the `scheme` value for identifying [DigestSecurityScheme]s.
const digestSecuritySchemeName = "digest";

const _defaultInValue = "header";

const _defaultQoPValue = "auth";

/// Digest Access Authentication security configuration identified by the
/// Vocabulary Term `digest`.
final class DigestSecurityScheme extends SecurityScheme {
  /// Constructor.
  const DigestSecurityScheme({
    this.in_ = _defaultInValue,
    this.qop = _defaultQoPValue,
    this.name,
    super.description,
    super.descriptions,
    super.proxy,
    super.jsonLdType,
    super.additionalFields,
  });

  /// Creates a [DigestSecurityScheme] from a [json] object.
  factory DigestSecurityScheme.fromJson(
    Map<String, dynamic> json,
    PrefixMapping prefixMapping,
    Set<String> parsedFields,
  ) {
    final description = json.parseField<String>("description", parsedFields);
    final descriptions =
        json.parseMapField<String>("descriptions", parsedFields);
    final jsonLdType = json.parseArrayField<String>("@type");
    final proxy = json.parseUriField("proxy", parsedFields);

    final name = json.parseField<String>("name", parsedFields);
    final in_ = json.parseField<String>("in", parsedFields) ?? _defaultInValue;
    final qop =
        json.parseField<String>("qop", parsedFields) ?? _defaultQoPValue;

    final additionalFields =
        json.parseAdditionalFields(prefixMapping, parsedFields);

    return DigestSecurityScheme(
      description: description,
      descriptions: descriptions,
      jsonLdType: jsonLdType,
      proxy: proxy,
      name: name,
      qop: qop,
      in_: in_,
      additionalFields: additionalFields,
    );
  }

  /// Name for query, header, cookie, or uri parameters.
  final String? name;

  /// Specifies the location of security authentication information.
  final String in_;

  /// Quality of protection.
  final String qop;

  @override
  String get scheme => digestSecuritySchemeName;

  @override
  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      "in": in_,
      "qop": qop,
      ...super.toJson(),
    };

    if (name != null) {
      result["name"] = name;
    }

    return result;
  }
}
