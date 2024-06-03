// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:curie/curie.dart";

import "../extensions/json_parser.dart";
import "security_scheme.dart";

const _defaultInValue = "header";
const _defaultAlgValue = "ES256";
const _defaultFormatValue = "jwt";

/// Indicates the `scheme` value for identifying [BearerSecurityScheme]s.
const bearerSecuritySchemeName = "bearer";

/// Bearer Token security configuration identified by the Vocabulary Term
/// `bearer`.
final class BearerSecurityScheme extends SecurityScheme {
  /// Constructor.
  const BearerSecurityScheme({
    this.name,
    this.alg = _defaultAlgValue,
    this.format = _defaultFormatValue,
    this.authorization,
    this.in_ = _defaultInValue,
    super.description,
    super.descriptions,
    super.proxy,
    super.jsonLdType,
    super.additionalFields,
  });

  /// Creates a [BearerSecurityScheme] from a [json] object.
  factory BearerSecurityScheme.fromJson(
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
    final format =
        json.parseField<String>("format", parsedFields) ?? _defaultFormatValue;
    final alg =
        json.parseField<String>("alg", parsedFields) ?? _defaultAlgValue;
    final authorization =
        json.parseField<String>("authorization", parsedFields);

    final additionalFields =
        json.parseAdditionalFields(prefixMapping, parsedFields);

    return BearerSecurityScheme(
      description: description,
      descriptions: descriptions,
      jsonLdType: jsonLdType,
      proxy: proxy,
      name: name,
      in_: in_,
      format: format,
      alg: alg,
      authorization: authorization,
      additionalFields: additionalFields,
    );
  }

  /// URI of the authorization server.
  final String? authorization;

  /// Name for query, header, cookie, or uri parameters.
  final String? name;

  /// Encoding, encryption, or digest algorithm.
  final String alg;

  /// Specifies format of security authentication information.
  final String format;

  /// Specifies the location of security authentication information.
  final String in_;

  @override
  String get scheme => bearerSecuritySchemeName;

  @override
  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      "in": in_,
      "alg": alg,
      "format": format,
      ...super.toJson(),
    };

    if (name != null) {
      result["name"] = name;
    }

    if (authorization != null) {
      result["authorization"] = authorization;
    }

    return result;
  }
}
