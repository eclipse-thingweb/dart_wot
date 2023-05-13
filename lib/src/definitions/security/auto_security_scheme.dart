// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:curie/curie.dart';

import 'security_scheme.dart';

const _schemeName = 'auto';

/// An automatic security configuration identified by the
/// vocabulary term `auto`.
final class AutoSecurityScheme extends SecurityScheme {
  /// Constructor.
  AutoSecurityScheme({
    super.description,
    super.descriptions,
    super.proxy,
    super.jsonLdType,
    super.additionalFields,
  }) : super(_schemeName);

  /// Creates an [AutoSecurityScheme] from a [json] object.
  AutoSecurityScheme.fromJson(
    Map<String, dynamic> json,
    PrefixMapping prefixMapping,
    Set<String> parsedFields,
  ) : super.fromJson(_schemeName, json, prefixMapping, parsedFields);
}
