// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:curie/curie.dart';

import '../data_schema.dart';
import '../thing_description.dart';
import 'interaction_affordance.dart';

/// Class representing an [Action] Affordance in a Thing Description.
class Action extends InteractionAffordance {
  /// Creates a new [Action] from a [List] of [forms].
  Action(super.forms, super.thingDescription);

  /// Creates a new [Action] from a [json] object.
  Action.fromJson(
    Map<String, dynamic> json,
    ThingDescription thingDescription,
    PrefixMapping prefixMapping,
  ) : super([], thingDescription) {
    final List<String> parsedFields = [];
    _parseActionFields(json, parsedFields);
    parseAffordanceFields(json, prefixMapping);
  }

  /// The schema of the [input] data this [Action] accepts.
  DataSchema? input;

  /// The schema of the [output] data this [Action] produces.
  DataSchema? output;

  bool _idempotent = false;

  /// Indicates whether the Action is idempotent (=true) or not.
  ///
  /// Informs whether the Action can be called repeatedly with the same result,
  /// if present, based on the same input.
  bool get idempotent => _idempotent;

  bool _safe = false;

  /// Signals if the Action is safe (=true) or not.
  ///
  /// Used to signal if there is no internal state (cf. resource state) is
  /// changed when invoking an Action. In that case responses can be cached as
  /// example.
  bool get safe => _safe;

  bool? _synchronous;

  /// Indicates whether the action is synchronous (=true) or not.
  ///
  /// A synchronous action means that the response of action contains all the
  /// information about the result of the action and no further querying about
  /// the status of the action is needed. Lack of this keyword means that no
  /// claim on the synchronicity of the action can be made.
  bool? get synchronous => _synchronous;

  T? _parseJsonValue<T>(
    Map<String, dynamic> json,
    String key,
    List<String> parsedFields,
  ) {
    parsedFields.add(key);
    final dynamic value = json[key];
    if (value is T) {
      return value;
    }

    return null;
  }

  void _parseIdempotent(
    Map<String, dynamic> json,
    List<String> parsedFields,
  ) {
    _idempotent =
        _parseJsonValue<bool>(json, 'idempotent', parsedFields) ?? _idempotent;
  }

  void _parseSafe(Map<String, dynamic> json, List<String> parsedFields) {
    _safe = _parseJsonValue<bool>(json, 'safe', parsedFields) ?? _safe;
  }

  void _parseSynchronous(
    Map<String, dynamic> json,
    List<String> parsedFields,
  ) {
    _synchronous = _parseJsonValue<bool>(json, 'synchronous', parsedFields);
  }

  void _parseActionFields(
    Map<String, dynamic> json,
    List<String> parsedFields,
  ) {
    _parseIdempotent(json, parsedFields);
    _parseSafe(json, parsedFields);
    _parseSynchronous(json, parsedFields);
  }
}
