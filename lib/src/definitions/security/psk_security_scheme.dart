// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:curie/curie.dart';

import '../extensions/json_parser.dart';
import 'security_scheme.dart';

const _schemeName = 'psk';

/// Pre-shared key authentication security configuration identified by the
/// Vocabulary Term `psk`.
final class PskSecurityScheme extends SecurityScheme {
  /// Constructor.
  PskSecurityScheme({
    this.identity,
    super.description,
    super.descriptions,
    super.proxy,
    super.jsonLdType,
    super.additionalFields,
  }) : super(_schemeName);

  /// Creates a [PskSecurityScheme] from a [json] object.
  PskSecurityScheme.fromJson(
    Map<String, dynamic> json,
    PrefixMapping prefixMapping,
    Set<String> parsedFields,
  )   : identity = json.parseField<String>('identity'),
        super.fromJson(_schemeName, json, prefixMapping, parsedFields);

  /// Name for query, header, cookie, or uri parameters.
  final String? identity;
}
