// Copyright 2023 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:collection/collection.dart";
import "package:curie/curie.dart";

import "../extensions/json_parser.dart";
import "security_scheme.dart";

/// Indicates the `scheme` value for identifying [ComboSecurityScheme]s.
const comboSecuritySchemeName = "combo";

/// A combination of other security schemes identified by the Vocabulary Term
/// `combo` (i.e., "scheme": "combo").
final class ComboSecurityScheme extends SecurityScheme {
  /// Constructor.
  const ComboSecurityScheme({
    this.allOf,
    this.oneOf,
    super.description,
    super.descriptions,
    super.proxy,
    super.jsonLdType,
    super.additionalFields,
  });

  /// Creates a [ComboSecurityScheme] from a [json] object.
  factory ComboSecurityScheme.fromJson(
    Map<String, dynamic> json,
    PrefixMapping prefixMapping,
    Set<String> parsedFields,
  ) {
    final description = json.parseField<String>("description", parsedFields);
    final descriptions =
        json.parseMapField<String>("descriptions", parsedFields);
    final jsonLdType = json.parseArrayField<String>("@type");
    final proxy = json.parseUriField("proxy", parsedFields);

    final oneOf = json.parseArrayField<String>(
      "oneOf",
      parsedFields: parsedFields,
      minimalSize: 2,
    );
    final allOf = json.parseArrayField<String>(
      "allOf",
      parsedFields: parsedFields,
      minimalSize: 2,
    );

    final count =
        [oneOf, allOf].whereNotNull().fold(0, (previous, _) => previous + 1);

    if (count != 1) {
      throw FormatException(
        "Expected exactly one of allOf or oneOf to be "
        "defined, but $count were given.",
      );
    }

    final additionalFields =
        json.parseAdditionalFields(prefixMapping, parsedFields);

    return ComboSecurityScheme(
      description: description,
      descriptions: descriptions,
      jsonLdType: jsonLdType,
      proxy: proxy,
      oneOf: oneOf,
      allOf: allOf,
      additionalFields: additionalFields,
    );
  }

  /// Array of two or more strings identifying other named security scheme
  /// definitions, any one of which, when satisfied, will allow access.
  ///
  /// Only one may be chosen for use.
  final List<String>? oneOf;

  /// Array of two or more strings identifying other named security scheme
  /// definitions, all of which must be satisfied for access.
  final List<String>? allOf;

  @override
  String get scheme => comboSecuritySchemeName;

  @override
  Map<String, dynamic> toJson() {
    final result = super.toJson();

    if (oneOf != null) {
      result["oneOf"] = oneOf;
    }

    if (allOf != null) {
      result["allOf"] = allOf;
    }

    return result;
  }
}
