// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:curie/curie.dart";

import "../extensions/json_parser.dart";

import "security_scheme.dart";

/// Indicates the `scheme` value for identifying [AceSecurityScheme]s.
const aceSecuritySchemeName = "ace:ACESecurityScheme";

/// Experimental ACE Security Scheme.
final class AceSecurityScheme extends SecurityScheme {
  /// Constructor.
  const AceSecurityScheme({
    this.as,
    this.audience,
    this.scopes,
    this.cnonce,
    super.description,
    super.descriptions,
    super.proxy,
    super.jsonLdType,
    super.additionalFields,
  });

  /// Creates an [AceSecurityScheme] from a [json] object.
  factory AceSecurityScheme.fromJson(
    Map<String, dynamic> json,
    PrefixMapping prefixMapping,
    Set<String> parsedFields,
  ) {
    final description = json.parseField<String>("description", parsedFields);
    final descriptions =
        json.parseMapField<String>("descriptions", parsedFields);
    final jsonLdType = json.parseArrayField<String>("@type");
    final proxy = json.parseUriField("proxy", parsedFields);

    final as = json.parseField<String>("ace:as", parsedFields);
    final cnonce = json.parseField<bool>("ace:cnonce", parsedFields);
    final audience = json.parseField<String>("ace:audience", parsedFields);
    final scopes =
        json.parseArrayField<String>("ace:scopes", parsedFields: parsedFields);

    final additionalFields =
        json.parseAdditionalFields(prefixMapping, parsedFields);

    return AceSecurityScheme(
      description: description,
      descriptions: descriptions,
      jsonLdType: jsonLdType,
      proxy: proxy,
      as: as,
      cnonce: cnonce,
      audience: audience,
      scopes: scopes,
      additionalFields: additionalFields,
    );
  }

  @override
  String get scheme => aceSecuritySchemeName;

  /// URI of the authorization server.
  final String? as;

  /// The intended audience for this [AceSecurityScheme].
  final String? audience;

  /// Set of authorization scope identifiers provided as an array.
  ///
  /// These are provided in tokens returned by an authorization server and
  /// associated with forms in order to identify what resources a client may
  /// access and how. The values associated with a form should be chosen from
  /// those defined in an [AceSecurityScheme] active on that form.
  final List<String>? scopes;

  /// Indicates whether a [cnonce] is required by the Resource Server.
  final bool? cnonce;

  @override
  Map<String, dynamic> toJson() {
    final result = super.toJson();

    if (as != null) {
      result["ace:as"] = as.toString();
    }

    if (audience != null) {
      result["ace:audience"] = audience;
    }

    if (scopes != null) {
      result["ace:scopes"] = scopes;
    }

    if (cnonce != null) {
      result["ace:cnonce"] = cnonce;
    }

    return result;
  }
}
