// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'validation/validation_exception.dart';

/// Communication metadata describing the expected response message for the
/// primary response.
class ExpectedResponse {
  /// Constructs a new [ExpectedResponse] object from a [contentType].
  ExpectedResponse(this.contentType);

  /// Creates an [ExpectedResponse] from a [json] object.
  ExpectedResponse.fromJson(Map<String, dynamic> json)
      : contentType = _parseContentType(json['contentType']) {
    for (final entry in json.entries) {
      if (entry.key == 'response') {
        continue;
      }

      additionalFields[entry.key] = entry.value;
    }
  }

  /// The [contentType] of this [ExpectedResponse] object.
  String contentType;

  /// Any other additional field will be included in this [Map].
  final Map<String, dynamic> additionalFields = <String, dynamic>{};

  static String _parseContentType(dynamic contentType) {
    if (contentType is! String) {
      throw ValidationException('contentType of response map is not a String!');
    }
    return contentType;
  }
}
