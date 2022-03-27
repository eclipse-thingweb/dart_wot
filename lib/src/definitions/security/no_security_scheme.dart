// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'helper_functions.dart';
import 'security_scheme.dart';

/// A security configuration corresponding to identified by the Vocabulary Term
/// `nosec`.
class NoSecurityScheme extends SecurityScheme {
  @override
  String get scheme => "nosec";

  final List<String> _parsedJsonFields = [];

  /// Creates a [NoSecurityScheme] from a [json] object.
  NoSecurityScheme.fromJson(Map<String, dynamic> json) {
    _parsedJsonFields.addAll(parseSecurityJson(this, json));
    parseAdditionalFields(additionalFields, json, _parsedJsonFields);
  }
}
