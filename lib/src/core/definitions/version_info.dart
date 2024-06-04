// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:curie/curie.dart";

import "extensions/json_parser.dart";

/// Metadata of a Thing that provides version information about the TD document.
///
/// If required, additional version information such as firmware and hardware
/// version (term definitions outside of the TD namespace) can be extended via
/// the TD Context Extension mechanism.
class VersionInfo {
  /// Constructor.
  VersionInfo(
    this.instance, {
    this.model,
    this.additionalFields = const {},
  });

  /// Creates a new [VersionInfo] instance from a [json] object.
  factory VersionInfo.fromJson(
    Map<String, dynamic> json,
    PrefixMapping prefixMapping,
  ) {
    final Set<String> parsedFields = {};

    final instance = json.parseRequiredField<String>("instance", parsedFields);
    final model = json.parseField<String>("model", parsedFields);
    final additionalFields =
        json.parseAdditionalFields(prefixMapping, parsedFields);

    return VersionInfo(
      instance,
      model: model,
      additionalFields: additionalFields,
    );
  }

  /// Provides a version indicator of this TD.
  final String instance;

  /// Provides a version indicator of the underlying TM.
  final String? model;

  /// Additional fields collected during the parsing of a JSON object.
  final Map<String, dynamic> additionalFields;

  /// Converts this [VersionInfo] to a [Map] resembling a JSON object.
  Map<String, dynamic> toJson() {
    final result = {
      "instance": instance,
      ...additionalFields,
    };

    if (model != null) {
      result["model"] = model;
    }

    return result;
  }
}
