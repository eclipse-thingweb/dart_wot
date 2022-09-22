// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:curie/curie.dart';

import '../extensions/json_parser.dart';
import '../form.dart';
import '../thing_description.dart';

/// Base class for Interaction Affordances (Properties, Actions, and Events).
abstract class InteractionAffordance {
  // TODO(JKRhb): Make fields final

  /// Creates a new [InteractionAffordance]. Accepts a [List] of [forms].
  InteractionAffordance(this.forms, this.thingDescription);

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
    for (final formJson in json['forms']) {
      if (formJson is Map<String, dynamic>) {
        forms.add(Form.fromJson(formJson, this));
      }
    }
  }

  /// Parses the [InteractionAffordance] contained in a [json] object.
  void parseAffordanceFields(
    Map<String, dynamic> json,
    PrefixMapping prefixMapping,
  ) {
    _parseForms(json, prefixMapping);

    title = json.parseField('title');
    titles = json.parseMapField<String>('titles');
    description = json.parseField('description');
    descriptions = json.parseMapField<String>('descriptions');
    uriVariables = json.parseMapField<dynamic>('uriVariables');
  }
}
