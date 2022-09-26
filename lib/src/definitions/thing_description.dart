// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:convert';

import 'package:curie/curie.dart';

import 'context_entry.dart';
import 'extensions/json_parser.dart';
import 'interaction_affordances/action.dart';
import 'interaction_affordances/event.dart';
import 'interaction_affordances/property.dart';
import 'link.dart';
import 'security/security_scheme.dart';
import 'thing_model.dart';
import 'validation/thing_description_schema.dart';

/// Represents a WoT Thing Description
class ThingDescription {
  /// Creates a [ThingDescription] from a [rawThingDescription] JSON [String].
  ThingDescription(this.rawThingDescription) {
    final rawThingDescription = this.rawThingDescription;
    if (rawThingDescription != null) {
      parseThingDescription(rawThingDescription);
    }
  }

  /// Creates a [ThingDescription] from a [json] object.
  ThingDescription.fromJson(Map<String, dynamic> json, {bool validate = true}) {
    if (validate) {
      final validationResult = thingDescriptionSchema.validate(json);
      if (!validationResult.isValid) {
        throw ThingDescriptionValidationException(
          json,
          validationResult.errors,
        );
      }
    }
    _parseJson(json);
  }

  /// Creates a [ThingDescription] from a [ThingModel].
  ThingDescription.fromThingModel(ThingModel thingModel)
      : rawThingModel = thingModel;

  /// The [String] representation of this [ThingDescription], if it was created
  /// from one.
  String? rawThingDescription;

  /// The corresponding [ThingModel] of this [ThingDescription], if it was
  /// created from one.
  ThingModel? rawThingModel;

  /// The [title] of this [ThingDescription].
  late String title;

  /// The [description] of this [ThingDescription].
  String? description;

  /// A [Map] of multi-language [titles].
  final Map<String, String> titles = {};

  /// A [Map] of multi-language [descriptions].
  final Map<String, String> descriptions = {};

  /// The JSON-LD `@context`, represented by a  [List] of [ContextEntry]s.
  final List<ContextEntry> context = [];

  /// Contains the values of the @context for CURIE expansion.
  final prefixMapping = PrefixMapping();

  /// A [Map] of [Property] Affordances.
  final Map<String, Property> properties = {};

  /// A [Map] of [Action] Affordances.
  final Map<String, Action> actions = {};

  /// A [Map] of [Event] Affordances.
  final Map<String, Event> events = {};

  /// A [List] of [Link]s.
  final List<Link> links = [];

  /// The [base] address of this [ThingDescription]. Might be `null`.
  Uri? base;

  /// The [id] of this [ThingDescription]. Might be `null`.
  String? id;

  /// A [List] of the [securityDefinitions] that are used as the default.
  ///
  /// Each entry has to be a key of the [securityDefinitions] Map.
  final List<String> security = [];

  /// A map of [SecurityScheme]s that can be used for secure communication.
  final Map<String, SecurityScheme> securityDefinitions = {};

  /// URI template variables as defined in [RFC 6570].
  ///
  /// [RFC 6570]: http://tools.ietf.org/html/rfc6570
  Map<String, Object?>? uriVariables;

  /// Determines the id of this [ThingDescription].
  ///
  /// As the [id] field of a [ThingDescription] is not mandatory, the [base] and
  /// the [title] are used as fallbacks.
  ///
  /// This can lead to unintended behavior if two Things should use the same
  /// [title] or if two [ThingDescription]s are using the same `base` address.
  /// However, there seems to be no better solution at the moment.
  // TODO(JKRhb): Revisit ID determination
  String get identifier {
    return id ?? base?.toString() ?? title;
  }

  /// Creates the [ThingDescription] fields from a JSON [String].
  void parseThingDescription(String thingDescription) {
    final thingDescriptionJson =
        jsonDecode(thingDescription) as Map<String, dynamic>;

    _parseJson(thingDescriptionJson);
  }

  void _parseJson(Map<String, dynamic> json) {
    // TODO: Move to constructor?
    final Set<String> parsedFields = {};

    context.addAll(ContextEntry.parseContext(json['@context'], prefixMapping));
    title = json.parseRequiredField<String>('title', parsedFields);
    titles.addAll(json.parseMapField<String>('titles', parsedFields) ?? {});
    description = json.parseField<String>('description', parsedFields);
    descriptions
        .addAll(json.parseMapField<String>('descriptions', parsedFields) ?? {});
    id = json.parseField<String>('id', parsedFields);
    base = Uri.tryParse(json.parseField<String>('base', parsedFields) ?? '');
    security
        .addAll(json.parseArrayField<String>('security', parsedFields) ?? []);

    final dynamic securityDefinitions = json['securityDefinitions'];
    if (securityDefinitions is Map<String, dynamic>) {
      _parseSecurityDefinitions(securityDefinitions);
    }

    uriVariables = json.parseMapField<dynamic>('uriVariables');

    final dynamic properties = json['properties'];
    if (properties is Map<String, dynamic>) {
      _parseProperties(properties);
    }
    final dynamic actions = json['actions'];
    if (actions is Map<String, dynamic>) {
      _parseActions(actions);
    }
    final dynamic events = json['events'];
    if (events is Map<String, dynamic>) {
      _parseEvents(events);
    }

    links.addAll(json.parseLinks(prefixMapping) ?? []);
  }

  void _parseProperties(Map<String, dynamic> json) {
    for (final property in json.entries) {
      final dynamic value = property.value;
      if (value is Map<String, dynamic>) {
        properties[property.key] =
            Property.fromJson(value, this, prefixMapping);
      }
    }
  }

  void _parseActions(Map<String, dynamic> json) {
    for (final action in json.entries) {
      final dynamic value = action.value;
      if (value is Map<String, dynamic>) {
        actions[action.key] = Action.fromJson(value, this, prefixMapping);
      }
    }
  }

  void _parseEvents(Map<String, dynamic> json) {
    for (final event in json.entries) {
      final dynamic value = event.value;
      if (value is Map<String, dynamic>) {
        events[event.key] = Event.fromJson(value, this, prefixMapping);
      }
    }
  }

  void _parseSecurityDefinitions(Map<String, dynamic> json) {
    for (final securityDefinition in json.entries) {
      final dynamic value = securityDefinition.value;
      if (value is Map<String, dynamic>) {
        final securityScheme = SecurityScheme.fromJson(value);
        if (securityScheme != null) {
          securityDefinitions[securityDefinition.key] = securityScheme;
        }
      }
    }
  }
}
