// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../extensions/json_parser.dart';

import 'security_scheme.dart';

/// Experimental ACE Security Scheme.
class AceSecurityScheme extends SecurityScheme {
  /// Constructor.
  AceSecurityScheme({
    String? description,
    this.as,
    this.audience,
    this.scopes,
    this.cnonce,
    Map<String, String>? descriptions,
  }) {
    this.description = description;
    this.descriptions.addAll(descriptions ?? {});
  }

  /// Creates an [AceSecurityScheme] from a [json] object.
  AceSecurityScheme.fromJson(Map<String, dynamic> json) {
    final Set<String> parsedFields = {};

    as = json.parseField<String>('ace:as', parsedFields);
    cnonce = json.parseField<bool>('ace:cnonce', parsedFields);
    audience = json.parseField<String>('ace:audience', parsedFields);
    scopes = json.parseArrayField<String>('ace:scopes', parsedFields);

    parseSecurityJson(json, parsedFields);
  }

  @override
  String get scheme => 'ace:ACESecurityScheme';

  /// URI of the authorization server.
  String? as;

  /// The intended audience for this [AceSecurityScheme].
  String? audience;

  /// Set of authorization scope identifiers provided as an array.
  ///
  /// These are provided in tokens returned by an authorization server and
  /// associated with forms in order to identify what resources a client may
  /// access and how. The values associated with a form should be chosen from
  /// those defined in an [AceSecurityScheme] active on that form.
  List<String>? scopes;

  /// Indicates whether a [cnonce] is required by the Resource Server.
  bool? cnonce;
}
