// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Communication metadata describing the expected response message for the
/// primary response.
@immutable
class AdditionalExpectedResponse {
  /// Constructs a new [AdditionalExpectedResponse] object from a [contentType].
  AdditionalExpectedResponse(
    this.contentType, {
    String? schema,
    bool? success,
  })  : _success = success,
        _schema = schema;

  /// Creates an [AdditionalExpectedResponse] from a [json] object.
  AdditionalExpectedResponse.fromJson(
      Map<String, dynamic> json, String formContentType)
      : contentType = _parseJson(json, 'contentType') ?? formContentType,
        _success = _parseJson(json, 'success'),
        _schema = _parseJson(json, 'schema') {
    const parsedFields = ['contentType', 'schema', 'success'];

    for (final entry in json.entries) {
      final key = entry.key;
      if (parsedFields.contains(key)) {
        continue;
      }

      additionalFields[key] = entry.value;
    }
  }

  static T? _parseJson<T>(Map<String, dynamic> json, String key) {
    final dynamic value = json[key];

    if (value is T) {
      return value;
    }

    return null;
  }

  /// The [contentType] of this [AdditionalExpectedResponse] object.
  final String contentType;

  final bool? _success;

  /// Signals if an additional response should not be considered an error.
  bool get success => _success ?? false;

  final String? _schema;

  /// Used to define the output data schema for an additional response if it
  /// differs from the default output data schema.
  ///
  /// Rather than a `DataSchema` object, the name of a previous definition given
  /// in a `schemaDefinitions` map must be used.
  String? get schema => _schema;

  /// Any other additional field will be included in this [Map].
  final Map<String, dynamic> additionalFields = <String, dynamic>{};

  @override
  bool operator ==(Object other) {
    if (other is! AdditionalExpectedResponse) {
      return false;
    }

    return other.success == success &&
        other.schema == schema &&
        other.contentType == contentType &&
        const MapEquality<String, dynamic>()
            .equals(other.additionalFields, additionalFields);
  }

  @override
  int get hashCode =>
      Object.hash(success, schema, contentType, additionalFields);
}
