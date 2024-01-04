// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:meta/meta.dart";

/// Class that contains metadata describing the configuration of a security
/// mechanism.
@immutable
abstract base class SecurityScheme {
  /// Constructor.
  const SecurityScheme({
    this.jsonLdType,
    this.description,
    this.proxy,
    this.descriptions,
    this.additionalFields,
  });

  /// The actual security [scheme] identifier.
  ///
  /// Can be one of `nosec`, `combo`, `basic`, `digest`, `bearer`, `psk`,
  /// `oauth2`, or `apikey`.
  String get scheme;

  /// The default [description] of this [SecurityScheme].
  final String? description;

  /// A [Map] of multi-language [descriptions].
  final Map<String, String>? descriptions;

  /// [Uri] of the proxy server this security configuration provides access to.
  ///
  /// If not given, the corresponding security configuration is for the
  /// endpoint.
  final Uri? proxy;

  /// A [List] of JSON-LD `@type` annotations.
  final List<String>? jsonLdType;

  /// Additional fields collected during the parsing of a JSON object.
  final Map<String, dynamic>? additionalFields;
}
