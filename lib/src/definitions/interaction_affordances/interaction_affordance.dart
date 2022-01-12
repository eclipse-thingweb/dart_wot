// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import '../form.dart';

/// Base class for Interaction Affordances (Properties, Actions, and Events).
abstract class InteractionAffordance {
  /// The default [title] of this [InteractionAffordance].
  String? title;

  /// Multilanguage [titles] of this [InteractionAffordance].
  Map<String, String>? titles;

  /// The default [description] of this [InteractionAffordance].
  String? description;

  /// Multilanguage [descriptions] of this [InteractionAffordance].
  Map<String, String>? descriptions;

  /// The basic [forms] which can be used for interacting with this resource.
  List<Form> forms;

  /// A list of [forms] augmented with additional information.
  ///
  /// This information includes base addresses and security definitions.
  List<Form> augmentedForms = [];

  /// Parses [forms] represented by a [json] object.
  void _parseForms(Map<String, dynamic> json) {
    for (final formJson in json["forms"]) {
      if (formJson is Map<String, dynamic>) {
        forms.add(Form.fromJson(formJson));
      }
    }
  }

  Map<String, String>? _parseMultilangString(
      Map<String, dynamic> json, String jsonKey) {
    Map<String, String>? field;
    final dynamic jsonEntries = json[jsonKey];
    if (jsonEntries is Map<String, dynamic>) {
      field = {};
      for (final entry in jsonEntries.entries) {
        final dynamic value = entry.value;
        if (value is String) {
          field[entry.key] = value;
        }
      }
    }
    return field;
  }

  /// Parses the [InteractionAffordance] contained in a [json] object.
  void parseAffordanceFields(Map<String, dynamic> json) {
    _parseForms(json);

    final dynamic title = json["title"];
    if (title is String) {
      this.title = title;
    }

    titles = _parseMultilangString(json, "titles");

    final dynamic description = json["description"];
    if (description is String) {
      this.description = description;
    }

    descriptions = _parseMultilangString(json, "descriptions");
  }

  /// Creates a new [InteractionAffordance]. Accepts a [List] of [forms].
  InteractionAffordance(this.forms);
}
