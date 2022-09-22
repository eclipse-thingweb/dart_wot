// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../extensions/json_parser.dart';
import 'ace_security_scheme.dart';
import 'apikey_security_scheme.dart';
import 'auto_security_scheme.dart';
import 'basic_security_scheme.dart';
import 'bearer_security_scheme.dart';
import 'digest_security_scheme.dart';
import 'no_security_scheme.dart';
import 'oauth2_security_scheme.dart';
import 'psk_security_scheme.dart';

/// Class that contains metadata describing the configuration of a security
/// mechanism.
abstract class SecurityScheme {
  /// Constructor.
  SecurityScheme({
    this.description,
    this.proxy,
    Map<String, String>? descriptions,
  }) {
    this.descriptions.addAll(descriptions ?? {});
  }

  /// The actual security [scheme] identifier.
  ///
  /// Can be one of `nosec`, `combo`, `basic`, `digest`, `bearer`, `psk`,
  /// `oauth2`, or `apikey`.
  String get scheme;

  /// The default [description] of this [SecurityScheme].
  String? description;

  /// A [Map] of multi-language [descriptions].
  Map<String, String> descriptions = {};

  ///
  String? proxy;

  /// A [List] of JSON-LD `@type` annotations.
  List<String>? jsonLdType = [];

  /// Additional fields collected during the parsing of a JSON object.
  final Map<String, dynamic> additionalFields = <String, dynamic>{};

  /// Parses the fields shared by all [SecurityScheme]s.
  void parseSecurityJson(
    Map<String, dynamic> json,
    Set<String> parsedFields,
  ) {
    parsedFields.add('scheme');

    proxy = json.parseField<String>('proxy', parsedFields);
    description = json.parseField<String>('description', parsedFields);
    descriptions
        .addAll(json.parseMapField<String>('descriptions', parsedFields) ?? {});
    jsonLdType = json.parseArrayField<String>('@type');

    additionalFields.addEntries(
      json.entries.where((jsonEntry) => !parsedFields.contains(jsonEntry.key)),
    );
  }

  /// Creates a [SecurityScheme] from a [json] object.
  static SecurityScheme? fromJson(Map<String, dynamic> json) {
    switch (json['scheme']) {
      case 'auto':
        return AutoSecurityScheme.fromJson(json);
      case 'basic':
        return BasicSecurityScheme.fromJson(json);
      case 'bearer':
        return BearerSecurityScheme.fromJson(json);
      case 'nosec':
        return NoSecurityScheme.fromJson(json);
      case 'psk':
        return PskSecurityScheme.fromJson(json);
      case 'digest':
        return DigestSecurityScheme.fromJson(json);
      case 'apikey':
        return ApiKeySecurityScheme.fromJson(json);
      case 'oauth2':
        return OAuth2SecurityScheme.fromJson(json);
      case 'ace:ACESecurityScheme':
        return AceSecurityScheme.fromJson(json);
    }

    return null;
  }
}
