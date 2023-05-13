// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:curie/curie.dart';

import '../extensions/json_parser.dart';
import 'security_scheme.dart';

const _defaultInValue = 'header';
const _defaultAlgValue = 'ES256';
const _defaultFormatValue = 'jwt';

const _schemeName = 'bearer';

/// Bearer Token security configuration identified by the Vocabulary Term
/// `bearer`.
class BearerSecurityScheme extends SecurityScheme {
  /// Constructor.
  BearerSecurityScheme({
    this.name,
    this.alg = _defaultAlgValue,
    this.format = _defaultFormatValue,
    this.authorization,
    this.in_ = _defaultInValue,
    super.description,
    super.descriptions,
    super.proxy,
    super.jsonLdType,
    super.additionalFields,
  }) : super(_schemeName);

  /// Creates a [BearerSecurityScheme] from a [json] object.
  BearerSecurityScheme.fromJson(
    Map<String, dynamic> json,
    PrefixMapping prefixMapping,
    Set<String> parsedFields,
  )   : name = json.parseField<String>('name', parsedFields),
        in_ = json.parseField<String>('in', parsedFields) ?? _defaultInValue,
        format = json.parseField<String>('format', parsedFields) ??
            _defaultFormatValue,
        alg = json.parseField<String>('alg', parsedFields) ?? _defaultAlgValue,
        authorization = json.parseField<String>('authorization', parsedFields),
        super.fromJson(_schemeName, json, prefixMapping, parsedFields);

  /// URI of the authorization server.
  final String? authorization;

  /// Name for query, header, cookie, or uri parameters.
  final String? name;

  /// Encoding, encryption, or digest algorithm.
  final String alg;

  /// Specifies format of security authentication information.
  final String format;

  /// Specifies the location of security authentication information.
  final String in_;
}
