// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:curie/curie.dart';

import 'extensions/json_parser.dart';

/// Communication metadata describing the expected response message for the
/// primary response.
class ExpectedResponse {
  /// Constructs a new [ExpectedResponse] object from a [contentType].
  ExpectedResponse(this.contentType, {Map<String, dynamic>? additionalFields})
      : additionalFields = Map.fromEntries(
          additionalFields?.entries
                  .where((element) => element.key != 'contentType') ??
              [],
        );

  /// Creates an [ExpectedResponse] from a [json] object.
  factory ExpectedResponse.fromJson(
    Map<String, dynamic> json,
    PrefixMapping prefixMapping,
  ) {
    final Set<String> parsedFields = {};

    final contentType =
        json.parseRequiredField<String>('contentType', parsedFields);
    final additionalFields =
        json.parseAdditionalFields(prefixMapping, parsedFields);

    return ExpectedResponse(contentType, additionalFields: additionalFields);
  }

  /// The [contentType] of this [ExpectedResponse] object.
  String contentType;

  /// Any other additional field will be included in this [Map].
  final Map<String, dynamic>? additionalFields;
}
