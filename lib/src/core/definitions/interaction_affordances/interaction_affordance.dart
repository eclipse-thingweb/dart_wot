// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

/// Sub-library for defining the three kinds of interaction affordances
/// (properties, actions, events).
library interaction_affordance;

import "package:curie/curie.dart";
import "package:meta/meta.dart";

import "../data_schema.dart";
import "../extensions/json_parser.dart";
import "../extensions/json_serializer.dart";
import "../extensions/serializable.dart";
import "../form.dart";

part "action.dart";
part "event.dart";
part "property.dart";

/// Base class for Interaction Affordances (Properties, Actions, and Events).
@immutable
sealed class InteractionAffordance implements Serializable {
  /// Creates a new [InteractionAffordance]. Accepts a [List] of [forms].
  const InteractionAffordance({
    required this.forms,
    this.atType,
    this.title,
    this.titles,
    this.description,
    this.descriptions,
    this.uriVariables,
    this.additionalFields = const {},
  });

  /// /// JSON-LD keyword to label the object with semantic tags (or types).
  final List<String>? atType;

  /// The default [title] of this [InteractionAffordance].
  final String? title;

  /// Multi-language [titles] of this [InteractionAffordance].
  final Map<String, String>? titles;

  /// The default [description] of this [InteractionAffordance].
  final String? description;

  /// Multi-language [descriptions] of this [InteractionAffordance].
  final Map<String, String>? descriptions;

  /// The basic [forms] which can be used for interacting with this resource.
  final List<Form> forms;

  /// URI template variables as defined in [RFC 6570].
  ///
  /// [RFC 6570]: http://tools.ietf.org/html/rfc6570
  final Map<String, DataSchema>? uriVariables;

  /// Additional fields that could not be deserialized as class members.
  final Map<String, dynamic> additionalFields;

  @mustCallSuper
  @override
  Map<String, dynamic> toJson() {
    final result = {
      "forms": forms.toJson(),
      ...additionalFields,
    };

    final keyValuePairs = [
      ("@type", atType),
      ("title", title),
      ("titles", titles),
      ("description", description),
      ("descriptions", descriptions),
      ("uriVariables", uriVariables),
    ];

    for (final (key, value) in keyValuePairs) {
      final dynamic convertedValue;

      switch (value) {
        case null:
          continue;
        case Map<String, DataSchema>():
          convertedValue = value.toJson();
        default:
          convertedValue = value;
      }

      result[key] = convertedValue;
    }

    return result;
  }
}
