// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../extensions/json_parser.dart';
import 'security_scheme.dart';

const _defaultInValue = 'header';

/// Basic Authentication security configuration identified by the Vocabulary
/// Term `basic`.
class BasicSecurityScheme extends SecurityScheme {
  /// Constructor.
  BasicSecurityScheme({
    super.description,
    super.proxy,
    this.name,
    String? in_,
    super.descriptions,
  }) : in_ = in_ ?? _defaultInValue;

  /// Creates a [BasicSecurityScheme] from a [json] object.
  BasicSecurityScheme.fromJson(Map<String, dynamic> json) {
    final Set<String> parsedFields = {};

    name = json.parseField<String>('name', parsedFields);
    in_ = json.parseField<String>('in', parsedFields) ?? _defaultInValue;

    parseSecurityJson(json, parsedFields);
  }

  @override
  String get scheme => 'basic';

  /// Name for query, header, cookie, or uri parameters.
  late final String? name;

  /// Specifies the location of security authentication information.
  late String in_ = 'header';
}
