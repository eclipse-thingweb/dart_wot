// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

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

  /// URI template variables as defined in [RFC 6570].
  ///
  /// [RFC 6570]: http://tools.ietf.org/html/rfc6570
  Map<String, Object?>? uriVariables;

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

    if (json["uriVariables"] != null) {
      final dynamic jsonUriVariables = json["uriVariables"];
      if (jsonUriVariables is Map<String, dynamic>) {
        uriVariables = jsonUriVariables;
      }
    }
  }

  /// Creates a new [InteractionAffordance]. Accepts a [List] of [forms].
  InteractionAffordance(this.forms);
}
