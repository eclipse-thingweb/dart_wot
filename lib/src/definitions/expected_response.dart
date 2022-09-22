// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

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
  static ExpectedResponse? fromJson(
    Map<String, dynamic> json, [
    Set<String>? parsedFields,
  ]) {
    final responseJson = json['response'];
    parsedFields?.add('response');

    if (responseJson is! Map<String, dynamic>) {
      return null;
    }

    return ExpectedResponse(
      responseJson.parseRequiredField<String>('contentType'),
      additionalFields: Map.fromEntries(
        responseJson.entries.where((element) => element.key != 'contentType'),
      ),
    );
  }

  /// The [contentType] of this [ExpectedResponse] object.
  String contentType;

  /// Any other additional field will be included in this [Map].
  final Map<String, dynamic> additionalFields;
}
