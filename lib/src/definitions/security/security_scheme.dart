// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

/// Class that contains metadata describing the configuration of a security
/// mechanism.
abstract class SecurityScheme {
  /// The actual security [scheme] identifier.
  ///
  /// Can be one of `nosec`, `combo`, `basic`, `digest`, `bearer`, `psk`,
  /// `oauth2`, or `apikey`.
  String get scheme;

  /// The default [description] of this [SecurityScheme].
  String? description;

  /// A [Map] of multi-language [descriptions].
  final Map<String, String> descriptions = {};

  ///
  String? proxy;

  /// A [List] of JSON-LD `@type` annotations.
  List<String>? jsonLdType = [];

  /// Additional fields collected during the parsing of a JSON object.
  final Map<String, dynamic> additionalFields = <String, dynamic>{};
}
