// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

part of "interaction_affordance.dart";

/// Class representing an [Event] Affordance in a Thing Description.
class Event extends InteractionAffordance {
  /// Creates a new [Event] from a [List] of [forms].
  const Event({
    required super.forms,
    super.title,
    super.titles,
    super.description,
    super.descriptions,
    super.uriVariables,
    this.subscription,
    this.data,
    this.cancellation,
    super.additionalFields,
  });

  /// Creates a new [Event] from a [json] object.
  factory Event.fromJson(
    Map<String, dynamic> json,
    PrefixMapping prefixMapping,
  ) {
    final Set<String> parsedFields = {};

    final title = json.parseField<String>("title", parsedFields);
    final titles = json.parseMapField<String>("titles", parsedFields);
    final description = json.parseField<String>("description", parsedFields);
    final descriptions =
        json.parseMapField<String>("descriptions", parsedFields);
    final uriVariables = json.parseDataSchemaMapField(
      "uriVariables",
      prefixMapping,
      parsedFields,
    );

    final subscription =
        json.parseDataSchemaField("subscription", prefixMapping, parsedFields);
    final data = json.parseDataSchemaField("data", prefixMapping, parsedFields);
    final cancellation =
        json.parseDataSchemaField("cancellation", prefixMapping, parsedFields);

    final forms = json.parseAffordanceForms(prefixMapping, parsedFields);
    final additionalFields =
        json.parseAdditionalFields(prefixMapping, parsedFields);

    final event = Event(
      forms: forms,
      title: title,
      titles: titles,
      description: description,
      descriptions: descriptions,
      uriVariables: uriVariables,
      subscription: subscription,
      data: data,
      cancellation: cancellation,
      additionalFields: additionalFields,
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
