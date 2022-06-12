// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'helper_functions.dart';
import 'security_scheme.dart';

const _defaultInValue = 'header';

const _defaultQoPValue = 'auth';

/// Digest Access Authentication security configuration identified by the
/// Vocabulary Term `digest`.
class DigestSecurityScheme extends SecurityScheme {
  /// Constructor.
  DigestSecurityScheme({
    String? description,
    String? proxy,
    this.name,
    String? in_,
    String? qop,
    Map<String, String>? descriptions,
  })  : _in = in_,
        _qop = qop {
    this.description = description;
    this.proxy = proxy;
    this.descriptions.addAll(descriptions ?? {});
  }

  /// Creates a [DigestSecurityScheme] from a [json] object.
  DigestSecurityScheme.fromJson(Map<String, dynamic> json)
      : name = _parseNameJson(json) {
    _parsedJsonFields
      ..addAll(parseSecurityJson(this, json))
      ..add('name');

    final dynamic jsonIn = _getJsonValue(json, 'in', _parsedJsonFields);
    if (jsonIn is String) {
      _in = jsonIn;
    }

    final dynamic jsonQop = _getJsonValue(json, 'qop', _parsedJsonFields);
    if (jsonQop is String) {
      _qop = jsonQop;
    }

    parseAdditionalFields(additionalFields, json, _parsedJsonFields);
  }

  @override
  String get scheme => 'digest';

  /// Name for query, header, cookie, or uri parameters.
  final String? name;

  String? _in;

  /// Specifies the location of security authentication information.
  String get in_ => _in ?? _defaultInValue;

  String? _qop;

  /// Quality of protection.
  String get qop => _qop ?? _defaultQoPValue;

  final List<String> _parsedJsonFields = [];

  static dynamic _getJsonValue(
    Map<String, dynamic> json,
    String key, [
    List<String>? parsedJsonFields,
  ]) {
    parsedJsonFields?.add(key);
    return json[key];
  }

  static String? _parseNameJson(Map<String, dynamic> json) {
    final dynamic jsonName = _getJsonValue(json, 'name');
    if (jsonName is String) {
      return jsonName;
    }

    return null;
  }
}
