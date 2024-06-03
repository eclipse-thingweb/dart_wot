// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:curie/curie.dart";
import "package:meta/meta.dart";

import "extensions/json_parser.dart";
import "extensions/serializable.dart";

/// Communication metadata describing the expected response message for the
/// primary response.
@immutable
class ExpectedResponse implements Serializable {
  /// Constructs a new [ExpectedResponse] object from a [contentType].
  const ExpectedResponse(
    this.contentType, {
    this.additionalFields = const {},
  });

  /// Creates an [ExpectedResponse] from a [json] object.
  factory ExpectedResponse.fromJson(
    Map<String, dynamic> json,
    PrefixMapping prefixMapping,
  ) {
    final Set<String> parsedFields = {};

    final contentType =
        json.parseRequiredField<String>("contentType", parsedFields);
    final additionalFields =
        json.parseAdditionalFields(prefixMapping, parsedFields);

    return ExpectedResponse(contentType, additionalFields: additionalFields);
  }

  /// The [contentType] of this [ExpectedResponse] object.
  final String contentType;

  /// Any other additional field will be included in this [Map].
  final Map<String, dynamic> additionalFields;

  @override
  Map<String, dynamic> toJson() => {
        "contentType": contentType,
        ...additionalFields,
      };
}
