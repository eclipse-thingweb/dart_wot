// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'security_scheme.dart';

/// A security configuration corresponding to identified by the Vocabulary Term
/// `nosec`.
class NoSecurityScheme extends SecurityScheme {
  /// Creates a [NoSecurityScheme] from a [json] object.
  NoSecurityScheme.fromJson(Map<String, dynamic> json) {
    parseSecurityJson(json, {});
  }

  @override
  String get scheme => 'nosec';
}
