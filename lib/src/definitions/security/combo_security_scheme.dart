// Copyright 2023 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:curie/curie.dart';

import '../extensions/json_parser.dart';
import 'security_scheme.dart';

const _schemeName = 'combo';

/// A combination of other security schemes identified by the Vocabulary Term
/// `combo` (i.e., "scheme": "combo").
class ComboSecurityScheme extends SecurityScheme {
  /// Constructor.
  ComboSecurityScheme({
    this.allOf,
    this.oneOf,
    super.description,
    super.descriptions,
    super.proxy,
  }) : super(_schemeName);

  /// Creates a [ComboSecurityScheme] from a [json] object.
  ComboSecurityScheme.fromJson(
    Map<String, dynamic> json,
    PrefixMapping prefixMapping,
    Set<String> parsedFields,
  )   : oneOf = json.parseArrayField<String>('oneOf', parsedFields),
        allOf = json.parseArrayField<String>('allOf', parsedFields),
        super(_schemeName) {
    parseSecurityJson(json, parsedFields, prefixMapping);
  }

  /// Array of two or more strings identifying other named security scheme
  /// definitions, any one of which, when satisfied, will allow access.
  ///
  /// Only one may be chosen for use.
  final List<String>? oneOf;

  /// Array of two or more strings identifying other named security scheme
  /// definitions, all of which must be satisfied for access.
  final List<String>? allOf;
}
