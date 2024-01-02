// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "extensions/json_parser.dart";

/// Class representing a WoT Thing Model.
///
/// See W3C WoT Thing Description Specificition, [section 10][spec link].
///
/// [spec link]: https://w3c.github.io/wot-thing-description/#thing-model
class ThingModel {
  /// Creates a new Thing Model instance.
  ThingModel({
    this.title,
    this.id,
  });

  /// Creates a new [ThingModel] from a [json] object.
  factory ThingModel.fromJson(
    Map<String, dynamic> json, {
    // ignore: avoid_unused_constructor_parameters
    bool validate = true,
  }) {
    final Set<String> parsedFields = {};

    final title = json.parseField<String>("title", parsedFields);
    final id = json.parseField<String>("id", parsedFields);

    return ThingModel(
      title: title,
      id: id,
    );
  }

  /// The [title] of this [ThingModel].
  final String? title;

  /// The [id] of this [ThingModel]. Might be `null`.
  final String? id;
}
