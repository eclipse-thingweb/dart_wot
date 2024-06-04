// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:curie/curie.dart";

import "../extensions/json_parser.dart";
import "security_scheme.dart";

const _defaultInValue = "header";

/// Indicates the `scheme` value for identifying [BasicSecurityScheme]s.
const basicSecuritySchemeName = "basic";

/// Basic Authentication security configuration identified by the Vocabulary
/// Term `basic`.
final class BasicSecurityScheme extends SecurityScheme {
  /// Constructor.
  const BasicSecurityScheme({
    this.name,
    this.in_ = _defaultInValue,
    super.description,
    super.descriptions,
    super.proxy,
    super.jsonLdType,
    super.additionalFields,
  });

  /// Creates a [BasicSecurityScheme] from a [json] object.
  factory BasicSecurityScheme.fromJson(
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

    final additionalFields =
        json.parseAdditionalFields(prefixMapping, parsedFields);

    return BasicSecurityScheme(
      description: description,
      descriptions: descriptions,
      jsonLdType: jsonLdType,
      proxy: proxy,
      name: name,
      in_: in_,
      additionalFields: additionalFields,
    );
  }

  /// Name for query, header, cookie, or uri parameters.
  final String? name;

  /// Specifies the location of security authentication information.
  final String in_;

  @override
  String get scheme => basicSecuritySchemeName;

  @override
  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      "in": in_,
      ...super.toJson(),
    };

    if (name != null) {
      result["name"] = name;
    }

    return result;
  }
}
