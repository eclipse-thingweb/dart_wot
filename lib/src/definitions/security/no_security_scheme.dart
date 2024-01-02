// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:curie/curie.dart";

import "security_scheme.dart";

const _schemeName = "nosec";

/// A security configuration corresponding to identified by the Vocabulary Term
/// `nosec`.
final class NoSecurityScheme extends SecurityScheme {
  /// Constructor.
  NoSecurityScheme({
    super.description,
    super.descriptions,
    super.proxy,
    super.jsonLdType,
    super.additionalFields,
  }) : super(_schemeName);

  /// Creates a [NoSecurityScheme] from a [json] object.
  NoSecurityScheme.fromJson(
    Map<String, dynamic> json,
    PrefixMapping prefixMapping,
    Set<String> parsedFields,
  ) : super.fromJson(_schemeName, json, prefixMapping, parsedFields);
}
