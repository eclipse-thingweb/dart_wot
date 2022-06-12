// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:curie/curie.dart';

import '../data_schema.dart';
import '../thing_description.dart';
import 'interaction_affordance.dart';

/// Class representing an [Event] Affordance in a Thing Description.
class Event extends InteractionAffordance {
  /// Creates a new [Event] from a [List] of [forms].
  Event(super.forms, super.thingDescription);

  /// Creates a new [Event] from a [json] object.
  Event.fromJson(Map<String, dynamic> json, ThingDescription thingDescription,
      PrefixMapping prefixMapping)
      : super([], thingDescription) {
    parseAffordanceFields(json, prefixMapping);
    _parseEventFields(json);
  }

  /// Defines data that needs to be passed upon [subscription].
  DataSchema? subscription;

  /// Defines the [DataSchema] of the Event instance messages pushed by the
  /// Thing.
  DataSchema? data;

  /// Defines any data that needs to be passed to cancel a subscription.
  DataSchema? cancellation;

  void _parseEventFields(Map<String, dynamic> json) {
    subscription = DataSchema.fromJson(json);
    data = DataSchema.fromJson(json);
    cancellation = DataSchema.fromJson(json);
  }
}
