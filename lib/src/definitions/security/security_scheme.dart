// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:curie/curie.dart";

import "../extensions/json_parser.dart";

/// Class that contains metadata describing the configuration of a security
/// mechanism.
base class SecurityScheme {
  /// Constructor.
  SecurityScheme(
    this.scheme, {
    this.jsonLdType,
    this.description,
    this.proxy,
    this.descriptions,
    this.additionalFields,
  });

  /// Creates a [SecurityScheme] from a [json] object.
  SecurityScheme.fromJson(
    this.scheme,
    Map<String, dynamic> json,
    PrefixMapping prefixMapping,
    Set<String> parsedFields,
  )   : proxy = json.parseUriField("proxy", parsedFields),
        description = json.parseField<String>("description", parsedFields),
        descriptions = json.parseMapField<String>("descriptions", parsedFields),
        jsonLdType = json.parseArrayField<String>("@type"),
        additionalFields =
            json.parseAdditionalFields(prefixMapping, parsedFields);

  /// The actual security [scheme] identifier.
  ///
  /// Can be one of `nosec`, `combo`, `basic`, `digest`, `bearer`, `psk`,
  /// `oauth2`, or `apikey`.
  final String scheme;

  /// The default [description] of this [SecurityScheme].
  final String? description;

  /// A [Map] of multi-language [descriptions].
  final Map<String, String>? descriptions;

  /// [Uri] of the proxy server this security configuration provides access to.
  ///
  /// If not given, the corresponding security configuration is for the
  /// endpoint.
  final Uri? proxy;

  /// A [List] of JSON-LD `@type` annotations.
  final List<String>? jsonLdType;

  /// Additional fields collected during the parsing of a JSON object.
  final Map<String, dynamic>? additionalFields;
}
