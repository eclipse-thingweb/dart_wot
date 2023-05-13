// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:curie/curie.dart';

import '../extensions/json_parser.dart';

import 'security_scheme.dart';

const _schemeName = 'ace:ACESecurityScheme';

/// Experimental ACE Security Scheme.
class AceSecurityScheme extends SecurityScheme {
  /// Constructor.
  AceSecurityScheme({
    this.as,
    this.audience,
    this.scopes,
    this.cnonce,
    super.description,
    super.descriptions,
    super.proxy,
    super.jsonLdType,
    super.additionalFields,
  }) : super(_schemeName);

  /// Creates an [AceSecurityScheme] from a [json] object.
  AceSecurityScheme.fromJson(
    Map<String, dynamic> json,
    PrefixMapping prefixMapping,
    Set<String> parsedFields,
  )   : as = json.parseField<String>('ace:as', parsedFields),
        cnonce = json.parseField<bool>('ace:cnonce', parsedFields),
        audience = json.parseField<String>('ace:audience', parsedFields),
        scopes = json.parseArrayField<String>('ace:scopes', parsedFields),
        super.fromJson(
          _schemeName,
          json,
          prefixMapping,
          parsedFields,
        );

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
}
