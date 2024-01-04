// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:curie/curie.dart";

import "../extensions/json_parser.dart";
import "security_scheme.dart";

/// Indicates the `scheme` value for identifying [AutoSecurityScheme]s.
const autoSecuritySchemeName = "auto";

/// An automatic security configuration identified by the
/// vocabulary term `auto`.
final class AutoSecurityScheme extends SecurityScheme {
  /// Constructor.
  const AutoSecurityScheme({
    super.description,
    super.descriptions,
    super.proxy,
    super.jsonLdType,
    super.additionalFields,
  });

  /// Creates an [AutoSecurityScheme] from a [json] object.
  factory AutoSecurityScheme.fromJson(
    Map<String, dynamic> json,
    PrefixMapping prefixMapping,
    Set<String> parsedFields,
  ) {
    final description = json.parseField<String>("description", parsedFields);
    final descriptions =
        json.parseMapField<String>("descriptions", parsedFields);
    final jsonLdType = json.parseArrayField<String>("@type");
    final proxy = json.parseUriField("proxy", parsedFields);

    final additionalFields =
        json.parseAdditionalFields(prefixMapping, parsedFields);

    return AutoSecurityScheme(
      description: description,
      descriptions: descriptions,
      jsonLdType: jsonLdType,
      proxy: proxy,
      additionalFields: additionalFields,
    );
  }

  @override
  String get scheme => autoSecuritySchemeName;
}
