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

/// Bearer Token security configuration identified by the Vocabulary Term
/// `bearer`.
class BearerSecurityScheme extends SecurityScheme {
  /// Constructor.
  BearerSecurityScheme({
    this.name,
    String? alg,
    String? format,
    this.authorization,
    String? in_,
    super.proxy,
    super.description,
    super.descriptions,
  })  : in_ = in_ ?? _defaultInValue,
        alg = alg ?? _defaultAlgValue,
        format = format ?? _defaultFormatValue;

  /// Creates a [BearerSecurityScheme] from a [json] object.
  BearerSecurityScheme.fromJson(
    Map<String, dynamic> json,
    PrefixMapping prefixMapping,
  ) {
    final Set<String> parsedFields = {};

    name = json.parseField<String>('name', parsedFields);
    in_ = json.parseField<String>('in', parsedFields) ?? _defaultInValue;
    format =
        json.parseField<String>('format', parsedFields) ?? _defaultFormatValue;
    alg = json.parseField<String>('alg', parsedFields) ?? _defaultAlgValue;
    authorization = json.parseField<String>('authorization', parsedFields);

    parseSecurityJson(json, parsedFields, prefixMapping);
  }

  @override
  String get scheme => 'bearer';

  /// URI of the authorization server.
  late final String? authorization;

  /// Name for query, header, cookie, or uri parameters.
  late final String? name;

  /// Encoding, encryption, or digest algorithm.
  late final String alg;

  /// Specifies format of security authentication information.
  late final String format;

  /// Specifies the location of security authentication information.
  late final String in_;
}
