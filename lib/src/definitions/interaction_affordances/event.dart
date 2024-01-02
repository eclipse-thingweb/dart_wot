// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:curie/curie.dart";
import "package:meta/meta.dart";

import "../data_schema.dart";
import "../extensions/json_parser.dart";
import "../thing_description.dart";
import "interaction_affordance.dart";

/// Class representing an [Event] Affordance in a Thing Description.
@immutable
class Event extends InteractionAffordance {
  /// Creates a new [Event] from a [List] of [forms].
  Event(
    super.thingDescription, {
    super.title,
    super.titles,
    super.description,
    super.descriptions,
    super.uriVariables,
    super.forms,
    this.subscription,
    this.data,
    this.cancellation,
  });

  /// Creates a new [Event] from a [json] object.
  factory Event.fromJson(
    Map<String, dynamic> json,
    ThingDescription thingDescription,
    PrefixMapping prefixMapping,
  ) {
    final Set<String> parsedFields = {};

    final title = json.parseField<String>("title", parsedFields);
    final titles = json.parseMapField<String>("titles", parsedFields);
    final description = json.parseField<String>("description", parsedFields);
    final descriptions =
        json.parseMapField<String>("descriptions", parsedFields);
    final uriVariables =
        json.parseMapField<dynamic>("uriVariables", parsedFields);

    final subscription =
        json.parseDataSchemaField("subscription", prefixMapping, parsedFields);
    final data = json.parseDataSchemaField("data", prefixMapping, parsedFields);
    final cancellation =
        json.parseDataSchemaField("cancellation", prefixMapping, parsedFields);

    final event = Event(
      thingDescription,
      title: title,
      titles: titles,
      description: description,
      descriptions: descriptions,
      uriVariables: uriVariables,
      subscription: subscription,
      data: data,
      cancellation: cancellation,
    );

    event.forms
        .addAll(json.parseAffordanceForms(event, prefixMapping, parsedFields));
    event.additionalFields.addAll(
      json.parseAdditionalFields(prefixMapping, parsedFields),
    );

    return event;
  }

  /// Defines data that needs to be passed upon [subscription].
  final DataSchema? subscription;

  /// Defines the [DataSchema] of the Event instance messages pushed by the
  /// Thing.
  final DataSchema? data;

  /// Defines any data that needs to be passed to cancel a subscription.
  final DataSchema? cancellation;
}
