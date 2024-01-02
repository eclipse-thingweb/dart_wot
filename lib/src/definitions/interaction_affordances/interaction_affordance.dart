// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:meta/meta.dart";

import "../form.dart";
import "../thing_description.dart";

/// Base class for Interaction Affordances (Properties, Actions, and Events).
@immutable
abstract class InteractionAffordance {
  // TODO(JKRhb): Make fields final

  /// Creates a new [InteractionAffordance]. Accepts a [List] of [forms].
  InteractionAffordance(
    this.thingDescription, {
    this.title,
    this.titles,
    this.description,
    this.descriptions,
    this.uriVariables,
    List<Form>? forms,
  }) {
    this.forms.addAll(forms ?? []);
  }

  /// Reference to the [ThingDescription] containing this
  /// [InteractionAffordance].
  final ThingDescription thingDescription;

  /// The default [title] of this [InteractionAffordance].
  final String? title;

  /// Multilanguage [titles] of this [InteractionAffordance].
  final Map<String, String>? titles;

  /// The default [description] of this [InteractionAffordance].
  final String? description;

  /// Multilanguage [descriptions] of this [InteractionAffordance].
  final Map<String, String>? descriptions;

  /// The basic [forms] which can be used for interacting with this resource.
  final List<Form> forms = [];

  /// URI template variables as defined in [RFC 6570].
  ///
  /// [RFC 6570]: http://tools.ietf.org/html/rfc6570
  final Map<String, Object?>? uriVariables;

  /// Additional fields that could not be deserialized as class members.
  final Map<String, dynamic> additionalFields = {};
}
