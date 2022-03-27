// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:convert';

import 'context_entry.dart';
import 'interaction_affordances/action.dart';
import 'interaction_affordances/event.dart';
import 'interaction_affordances/property.dart';
import 'link.dart';
import 'security/apikey_security_scheme.dart';
import 'security/basic_security_scheme.dart';
import 'security/bearer_security_scheme.dart';
import 'security/digest_security_scheme.dart';
import 'security/no_security_scheme.dart';
import 'security/oauth2_security_scheme.dart';
import 'security/psk_security_scheme.dart';
import 'security/security_scheme.dart';
import 'thing_model.dart';

/// Represents a WoT Thing Description
class ThingDescription {
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

  /// A [Map] of [Property] Affordances.
  final Map<String, Property> properties = {};

  /// A [Map] of [Action] Affordances.
  final Map<String, Action> actions = {};

  /// A [Map] of [Event] Affordances.
  final Map<String, Event> events = {};

  /// A [List] of [Link]s.
  final List<Link> links = [];

  /// The [base] address of this [ThingDescription]. Might be `null`.
  String? base;

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
    return id ?? base ?? title;
  }

  /// Creates a [ThingDescription] from a [rawThingDescription] JSON [String].
  ThingDescription(this.rawThingDescription) {
    parseThingDescription(rawThingDescription!);
  }

  /// Creates a [ThingDescription] from a [json] object.
  ThingDescription.fromJson(Map<String, dynamic> json) {
    _parseJson(json);
  }

  /// Creates the [ThingDescription] fields from a JSON [String].
  void parseThingDescription(String thingDescription) {
    final thingDescriptionJson =
        jsonDecode(thingDescription) as Map<String, dynamic>;

    _parseJson(thingDescriptionJson);
  }

  void _parseJson(Map<String, dynamic> json) {
    _parseTitle(json["title"]);
    _parseContext(json["@context"]);
    final dynamic id = json["id"];
    if (id is String) {
      this.id = id;
    }
    final dynamic base = json["base"];
    if (base is String) {
      this.base = base;
    }
    final dynamic description = json["description"];
    if (description is String) {
      this.description = description;
    }
    _parseMultilangString(titles, json, "titles");
    _parseMultilangString(descriptions, json, "descriptions");
    final dynamic properties = json["properties"];
    if (properties is Map<String, dynamic>) {
      _parseProperties(properties);
    }
    final dynamic actions = json["actions"];
    if (actions is Map<String, dynamic>) {
      _parseActions(actions);
    }
    final dynamic events = json["events"];
    if (events is Map<String, dynamic>) {
      _parseEvents(events);
    }
    final dynamic security = json["security"];
    if (security is List<dynamic>) {
      this.security.addAll(security.whereType<String>());
    } else if (security is String) {
      this.security.add(security);
    }
    final dynamic securityDefinitions = json["securityDefinitions"];
    if (securityDefinitions is Map<String, dynamic>) {
      _parseSecurityDefinitions(securityDefinitions);
    }
    final dynamic links = json["links"];
    if (links is List<dynamic>) {
      _parseLinks(links);
    }
    final dynamic jsonUriVariables = json["uriVariables"];
    if (jsonUriVariables is Map<String, dynamic>) {
      uriVariables = jsonUriVariables;
    }
  }

  // TODO(JKRhb): Refactor
  void _parseMultilangString(
      Map<String, String> field, Map<String, dynamic> json, String jsonKey) {
    final dynamic jsonEntries = json[jsonKey];
    if (jsonEntries is Map<String, dynamic>) {
      for (final entry in jsonEntries.entries) {
        final dynamic value = entry.value;
        if (value is String) {
          field[entry.key] = value;
        }
      }
    }
  }

  void _parseTitle(dynamic titleJson) {
    if (titleJson is String) {
      title = titleJson;
    } else {
      throw ArgumentError("Thing Description type is not a "
          "String but ${title.runtimeType}");
    }
  }

  void _parseContext(dynamic contextJson) {
    if (contextJson is String || contextJson is Map<String, dynamic>) {
      _parseContextListEntry(contextJson);
    } else if (contextJson is List<dynamic>) {
      for (final contextEntry in contextJson) {
        _parseContextListEntry(contextEntry);
      }
    }
  }

  void _parseContextListEntry(dynamic contextJsonListEntry) {
    if (contextJsonListEntry is String) {
      context.add(ContextEntry(contextJsonListEntry, null));
    } else if (contextJsonListEntry is Map<String, dynamic>) {
      for (final mapEntry in contextJsonListEntry.entries) {
        if (mapEntry.value is String) {
          context.add(ContextEntry(mapEntry.value as String, mapEntry.key));
        }
      }
    }
  }

  /// Creates a [ThingDescription] from a [ThingModel].
  ThingDescription.fromThingModel(ThingModel thingModel)
      : rawThingModel = thingModel;

  void _parseLinks(List<dynamic> json) {
    for (final link in json) {
      if (link is Map<String, dynamic>) {
        links.add(Link.fromJson(link));
      }
    }
  }

  void _parseProperties(Map<String, dynamic> json) {
    for (final property in json.entries) {
      if (property.value is Map<String, dynamic>) {
        properties[property.key] =
            Property.fromJson(property.value as Map<String, dynamic>);
      }
    }
  }

  void _parseActions(Map<String, dynamic> json) {
    for (final action in json.entries) {
      if (action.value is Map<String, dynamic>) {
        actions[action.key] =
            Action.fromJson(action.value as Map<String, dynamic>);
      }
    }
  }

  void _parseEvents(Map<String, dynamic> json) {
    for (final event in json.entries) {
      if (event.value is Map<String, dynamic>) {
        events[event.key] = Event.fromJson(event.value as Map<String, dynamic>);
      }
    }
  }

  void _parseSecurityDefinitions(Map<String, dynamic> json) {
    for (final securityDefinition in json.entries) {
      final dynamic value = securityDefinition.value;
      if (value is Map<String, dynamic>) {
        SecurityScheme securityScheme;
        switch (value["scheme"]) {
          case "basic":
            {
              securityScheme = BasicSecurityScheme.fromJson(value);
              break;
            }
          case "bearer":
            {
              securityScheme = BearerSecurityScheme.fromJson(value);
              break;
            }
          case "nosec":
            {
              securityScheme = NoSecurityScheme.fromJson(value);
              break;
            }
          case "psk":
            {
              securityScheme = PskSecurityScheme.fromJson(value);
              break;
            }
          case "digest":
            {
              securityScheme = DigestSecurityScheme.fromJson(value);
              break;
            }
          case "apikey":
            {
              securityScheme = ApiKeySecurityScheme.fromJson(value);
              break;
            }
          case "oauth2":
            {
              securityScheme = OAuth2SecurityScheme.fromJson(value);
              break;
            }
          default:
            continue;
        }
        securityDefinitions[securityDefinition.key] = securityScheme;
      }
    }
  }
}
