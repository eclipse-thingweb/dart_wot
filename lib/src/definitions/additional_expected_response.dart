// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:collection/collection.dart';

/// Communication metadata describing the expected response message for the
/// primary response.
class AdditionalExpectedResponse {
  /// The [contentType] of this [AdditionalExpectedResponse] object.
  final String contentType;

  bool? _success;

  /// Signals if an additional response should not be considered an error.
  bool get success => _success ?? false;

  String? _schema;

  /// Used to define the output data schema for an additional response if it
  /// differs from the default output data schema.
  ///
  /// Rather than a `DataSchema` object, the name of a previous definition given
  /// in a `schemaDefinitions` map must be used.
  String? get schema => _schema;

  /// Any other additional field will be included in this [Map].
  final Map<String, dynamic> additionalFields = <String, dynamic>{};

  /// Constructs a new [AdditionalExpectedResponse] object from a [contentType].
  AdditionalExpectedResponse(
    this.contentType, {
    String? schema,
    bool? success,
  })  : _success = success,
        _schema = schema;

  static String? _parseContentType(dynamic contentType) {
    if (contentType is! String) {
      return null;
    }
    return contentType;
  }

  /// Creates an [AdditionalExpectedResponse] from a [json] object.
  AdditionalExpectedResponse.fromJson(
      Map<String, dynamic> json, String formContentType)
      : contentType =
            _parseContentType(json["contentType"]) ?? formContentType {
    const parsedFields = ["contentType", "schema", "success"];

    final dynamic success = json["success"];
    if (success is bool) {
      _success = success;
    }

    final dynamic schema = json["schema"];
    if (schema is String) {
      _schema = schema;
    }

    for (final entry in json.entries) {
      final key = entry.key;
      if (parsedFields.contains(key)) {
        continue;
      }

      additionalFields[key] = entry.value;
    }
  }

  @override
  bool operator ==(Object? other) {
    if (other is! AdditionalExpectedResponse) {
      return false;
    }

    return other.success == success &&
        other.schema == schema &&
        other.contentType == contentType &&
        MapEquality<String, dynamic>()
            .equals(other.additionalFields, additionalFields);
  }

  @override
  int get hashCode =>
      Object.hash(success, schema, contentType, additionalFields);
}
