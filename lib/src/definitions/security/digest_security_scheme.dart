// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:curie/curie.dart';

import '../extensions/json_parser.dart';
import 'security_scheme.dart';

const _defaultInValue = 'header';

const _defaultQoPValue = 'auth';

/// Digest Access Authentication security configuration identified by the
/// Vocabulary Term `digest`.
class DigestSecurityScheme extends SecurityScheme {
  /// Constructor.
  DigestSecurityScheme({
    this.in_ = _defaultInValue,
    this.qop = _defaultQoPValue,
    this.name,
    super.description,
    super.descriptions,
    super.proxy,
    super.jsonLdType,
    super.additionalFields,
  }) : super('digest');

  /// Creates a [DigestSecurityScheme] from a [json] object.
  DigestSecurityScheme.fromJson(
    Map<String, dynamic> json,
    PrefixMapping prefixMapping,
    Set<String> parsedFields,
  )   : name = json.parseField<String>('name', parsedFields),
        in_ = json.parseField<String>('in', parsedFields) ?? _defaultInValue,
        qop = json.parseField<String>('qop', parsedFields) ?? _defaultInValue,
        super.fromJson('digest', json, prefixMapping, parsedFields);

  /// Name for query, header, cookie, or uri parameters.
  final String? name;

  /// Specifies the location of security authentication information.
  final String in_;

  /// Quality of protection.
  final String qop;
}
