// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'security_scheme.dart';

/// Parses the fields shared by all [SecurityScheme]s.
List<String> parseSecurityJson(
    SecurityScheme securityScheme, Map<String, dynamic> json) {
  final List<String> parsedJsonFields = ["scheme"];

  final dynamic proxy = json["proxy"];
  if (proxy is String) {
    securityScheme.proxy = proxy;
  }

  final dynamic description = json["description"];
  if (description is String) {
    securityScheme.description = description;
  }

  final dynamic descriptions = json["descriptions"];
  if (descriptions is Map<String, dynamic>) {
    for (final entry in descriptions.entries) {
      final dynamic value = entry.value;
      if (value is String) {
        securityScheme.descriptions[entry.key] = value;
      }
    }
  }

  final dynamic jsonLdType = json["@type"];
  if (jsonLdType is String) {
    securityScheme.jsonLdType = [jsonLdType];
  } else if (jsonLdType is List<dynamic>) {
    securityScheme.jsonLdType =
        jsonLdType.whereType<String>().toList(growable: false);
  }

  return parsedJsonFields;
}

/// Parses additional fields which are not part of the WoT specification.
void parseAdditionalFields(Map<String, dynamic> additionalFields,
    Map<String, dynamic> json, List<String> parsedJsonFields) {
  final additionEntries = json.entries
      .where((jsonEntry) => !parsedJsonFields.contains(jsonEntry.key));
  additionalFields.addEntries(additionEntries);
}
