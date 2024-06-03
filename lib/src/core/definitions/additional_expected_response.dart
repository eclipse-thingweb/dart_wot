// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:collection/collection.dart";
import "package:curie/curie.dart";
import "package:meta/meta.dart";

import "extensions/json_parser.dart";
import "extensions/serializable.dart";

/// Communication metadata describing the expected response message for the
/// primary response.
@immutable
class AdditionalExpectedResponse implements Serializable {
  /// Constructs a new [AdditionalExpectedResponse] object from a [contentType].
  const AdditionalExpectedResponse(
    this.contentType, {
    this.schema,
    this.success = false,
    this.additionalFields = const {},
  });

  /// Creates an [AdditionalExpectedResponse] from a [json] object.
  factory AdditionalExpectedResponse.fromJson(
    Map<String, dynamic> json,
    String formContentType,
    PrefixMapping prefixMapping,
  ) {
    final Set<String> parsedFields = {};

    final contentType =
        json.parseField<String>("contentType", parsedFields) ?? formContentType;
    final success = json.parseField<bool>("success", parsedFields) ?? false;
    final schema = json.parseField<String>("schema", parsedFields);
    final additionalFields =
        json.parseAdditionalFields(prefixMapping, parsedFields);

    return AdditionalExpectedResponse(
      contentType,
      schema: schema,
      success: success,
      additionalFields: additionalFields,
    );
  }

  /// The [contentType] of this [AdditionalExpectedResponse] object.
  final String contentType;

  /// Signals if an additional response should not be considered an error.
  ///
  /// Defaults to `false` if not explicitly set.
  final bool success;

  /// Used to define the output data schema for an additional response if it
  /// differs from the default output data schema.
  ///
  /// Rather than a `DataSchema` object, the name of a previous definition given
  /// in a `schemaDefinitions` map must be used.
  final String? schema;

  /// Any other additional field will be included in this [Map].
  final Map<String, dynamic> additionalFields;

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

  @override
  Map<String, dynamic> toJson() {
    final result = {
      "contentType": contentType,
      ...additionalFields,
    };

    if (success) {
      result["success"] = success;
    }

    if (schema != null) {
      result["schema"] = schema;
    }

    return result;
  }
}
