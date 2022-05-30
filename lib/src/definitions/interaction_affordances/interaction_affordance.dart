// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:curie/curie.dart';

import '../form.dart';
import '../thing_description.dart';

/// Base class for Interaction Affordances (Properties, Actions, and Events).
abstract class InteractionAffordance {
  // TODO(JKRhb): Make fields final

  /// Reference to the [ThingDescription] containing this
  /// [InteractionAffordance].
  final ThingDescription thingDescription;

  /// The default [title] of this [InteractionAffordance].
  String? title;

  /// Multilanguage [titles] of this [InteractionAffordance].
  Map<String, String>? titles;

  /// The default [description] of this [InteractionAffordance].
  String? description;

  /// Multilanguage [descriptions] of this [InteractionAffordance].
  Map<String, String>? descriptions;

  /// The basic [forms] which can be used for interacting with this resource.
  final List<Form> forms;

  /// URI template variables as defined in [RFC 6570].
  ///
  /// [RFC 6570]: http://tools.ietf.org/html/rfc6570
  Map<String, Object?>? uriVariables;

  /// Parses [forms] represented by a [json] object.
  void _parseForms(Map<String, dynamic> json, PrefixMapping prefixMapping) {
    for (final formJson in json["forms"]) {
      if (formJson is Map<String, dynamic>) {
        forms.add(Form.fromJson(formJson, this));
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
  void parseAffordanceFields(
      Map<String, dynamic> json, PrefixMapping prefixMapping) {
    _parseForms(json, prefixMapping);

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
  InteractionAffordance(this.forms, this.thingDescription);
}
