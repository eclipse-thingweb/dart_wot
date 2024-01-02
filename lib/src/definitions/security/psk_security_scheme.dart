// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:curie/curie.dart";

import "../extensions/json_parser.dart";
import "security_scheme.dart";

/// Indicates the `scheme` value for identifying [PskSecurityScheme]s.
const pskSecuritySchemeName = "psk";

/// Pre-shared key authentication security configuration identified by the
/// Vocabulary Term `psk`.
final class PskSecurityScheme extends SecurityScheme {
  /// Constructor.
  const PskSecurityScheme({
    this.identity,
    super.description,
    super.descriptions,
    super.proxy,
    super.jsonLdType,
    super.additionalFields,
  });

  /// Creates a [PskSecurityScheme] from a [json] object.
  factory PskSecurityScheme.fromJson(
    Map<String, dynamic> json,
    PrefixMapping prefixMapping,
    Set<String> parsedFields,
  ) {
    final description = json.parseField<String>("description", parsedFields);
    final descriptions =
        json.parseMapField<String>("descriptions", parsedFields);
    final jsonLdType = json.parseArrayField<String>("@type");
    final proxy = json.parseUriField("proxy", parsedFields);

    final identity = json.parseField<String>("identity");

    final additionalFields =
        json.parseAdditionalFields(prefixMapping, parsedFields);

    return PskSecurityScheme(
      description: description,
      descriptions: descriptions,
      jsonLdType: jsonLdType,
      proxy: proxy,
      identity: identity,
      additionalFields: additionalFields,
    );
  }

  /// Name for query, header, cookie, or uri parameters.
  final String? identity;

  @override
  String get scheme => pskSecuritySchemeName;
}
