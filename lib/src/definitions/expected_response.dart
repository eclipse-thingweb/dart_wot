// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

/// Communication metadata describing the expected response message for the
/// primary response.
class ExpectedResponse {
  /// The [contentType] of this [ExpectedResponse] object.
  String contentType;

  /// Any other additional field will be included in this [Map].
  final Map<String, dynamic> additionalFields = <String, dynamic>{};

  /// Constructs a new [ExpectedResponse] object from a [contentType].
  ExpectedResponse(this.contentType);

  static String _parseContentType(dynamic contentType) {
    if (contentType is! String) {
      throw ArgumentError("contentType of response map is not a String!");
    }
    return contentType;
  }

  /// Creates an [ExpectedResponse] from a [json] object.
  ExpectedResponse.fromJson(Map<String, dynamic> json)
      : contentType = _parseContentType(json["contentType"]) {
    for (final entry in json.entries) {
      if (entry.key == "response") {
        continue;
      }

      additionalFields[entry.key] = entry.value;
    }
  }
}
