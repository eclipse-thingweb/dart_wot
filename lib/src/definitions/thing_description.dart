// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:curie/curie.dart";
import "package:meta/meta.dart";

import "additional_expected_response.dart";
import "data_schema.dart";
import "extensions/json_parser.dart";
import "form.dart";
import "interaction_affordances/interaction_affordance.dart";
import "link.dart";
import "security/security_scheme.dart";
import "thing_model.dart";
import "validation/thing_description_schema.dart";
import "version_info.dart";

/// Type definition for a JSON-LD @context entry.
typedef ContextEntry = ({String? key, String value});

/// Represents a WoT Thing Description
@immutable
class ThingDescription {
  /// Creates a new Thing Description object.
  const ThingDescription._({
    required this.context,
    required this.title,
    required this.security,
    required this.securityDefinitions,
    this.titles,
    this.atType,
    this.id,
    this.descriptions,
    this.created,
    this.modified,
    this.support,
    this.base,
    this.properties,
    this.actions,
    this.events,
    this.links,
    this.forms,
    this.profile,
    this.schemaDefinitions,
    this.additionalFields,
    this.description,
    this.version,
    this.uriVariables,
    this.prefixMapping,
  });

  /// Creates a [ThingDescription] from a [json] object.

  factory ThingDescription.fromJson(
    Map<String, dynamic> json, {
    bool validate = true,
  }) {
    if (validate) {
      final validationResult = thingDescriptionSchema.validate(json);
      if (!validationResult.isValid) {
        throw ThingDescriptionValidationException(
          json,
          validationResult.errors,
        );
      }
    }

    final Set<String> parsedFields = {};
    final prefixMapping = PrefixMapping();

    final context = json.parseContext(prefixMapping, parsedFields);
    final atType = json.parseArrayField<String>("@type", parsedFields);
    final title = json.parseRequiredField<String>("title", parsedFields);
    final titles = json.parseMapField<String>("titles", parsedFields);
    final description = json.parseField<String>("description", parsedFields);
    final descriptions =
        json.parseMapField<String>("descriptions", parsedFields);
    final version = json.parseVersionInfo(prefixMapping, parsedFields);
    final created = json.parseDateTime("created", parsedFields);
    final modified = json.parseDateTime("modified", parsedFields);
    final support = json.parseUriField("support", parsedFields);
    final base = json.parseUriField("base", parsedFields);
    final id = json.parseField<String>("id", parsedFields);

    final security =
        json.parseArrayField<String>("security", parsedFields) ?? [];

    final securityDefinitions =
        json.parseSecurityDefinitions(prefixMapping, parsedFields) ?? {};

    final forms = json.parseForms(prefixMapping, parsedFields);

    final properties = json.parseProperties(prefixMapping, parsedFields);
    final actions = json.parseActions(prefixMapping, parsedFields);
    final events = json.parseEvents(prefixMapping, parsedFields);

    final links = json.parseLinks(prefixMapping, parsedFields);

    final profile = json.parseUriArrayField("profile", parsedFields);
    final schemaDefinitions = json.parseDataSchemaMapField(
      "schemaDefinitions",
      prefixMapping,
      parsedFields,
    );
    final uriVariables =
        json.parseMapField<Object>("uriVariables", parsedFields);
    final additionalFields =
        json.parseAdditionalFields(prefixMapping, parsedFields);

    return ThingDescription._(
      prefixMapping: prefixMapping,
      context: context,
      title: title,
      titles: titles,
      description: description,
      descriptions: descriptions,
      version: version,
      created: created,
      modified: modified,
      support: support,
      base: base,
      id: id,
      forms: forms,
      properties: properties,
      actions: actions,
      events: events,
      links: links,
      profile: profile,
      schemaDefinitions: schemaDefinitions,
      uriVariables: uriVariables,
      additionalFields: additionalFields,
      security: security,
      securityDefinitions: securityDefinitions,
      atType: atType,
    );
  }

  /// Creates a [ThingDescription] from a [ThingModel].
  // ignore: avoid_unused_constructor_parameters
  factory ThingDescription.fromThingModel(ThingModel thingModel) {
    throw UnimplementedError();
  }

  /// Converts this [ThingDescription] to a [Map] resembling a JSON objct.
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }

  /// Contains the values of the @context for CURIE expansion.
  final PrefixMapping? prefixMapping;

  /// The JSON-LD `@context`, represented by a  [List] of [ContextEntry]s.
  final List<ContextEntry> context;

  /// JSON-LD keyword to label the object with semantic tags (or types).
  final List<String>? atType;

  /// The [id] of this [ThingDescription]. Might be `null`.
  final String? id;

  /// The [title] of this [ThingDescription].
  final String title;

  /// A [Map] of multi-language [titles].
  final Map<String, String>? titles;

  /// The [description] of this [ThingDescription].
  final String? description;

  /// A [Map] of multi-language [descriptions].
  final Map<String, String>? descriptions;

  /// Provides version information.
  final VersionInfo? version;

  /// Provides information when the TD instance was created.
  final DateTime? created;

  /// Provides information when the TD instance was last modified.
  final DateTime? modified;

  /// Provides information about the TD maintainer as URI scheme (e.g., `mailto`
  /// [RFC 6068], `tel` [RFC 3966], `https` [RFC 9112]).
  ///
  /// [RFC 6068]:https://datatracker.ietf.org/doc/html/rfc6068
  /// [RFC 3966]: https://datatracker.ietf.org/doc/html/rfc3966
  /// [RFC 9112]: https://datatracker.ietf.org/doc/html/rfc9112
  final Uri? support;

  /// The [base] address of this [ThingDescription]. Might be `null`.
  final Uri? base;

  /// A [Map] of [Property] Affordances.
  final Map<String, Property>? properties;

  /// A [Map] of [Action] Affordances.
  final Map<String, Action>? actions;

  /// A [Map] of [Event] Affordances.
  final Map<String, Event>? events;

  /// A [List] of [Link]s.
  final List<Link>? links;

  /// Set of form hypermedia controls that describe how an operation can be
  /// performed.
  ///
  /// [Form]s are serializations of Protocol Bindings.
  /// Thing-level forms are used to describe endpoints for a group of
  /// interaction affordances.
  final List<Form>? forms;

  /// A [List] of the [securityDefinitions] that are used as the default.
  ///
  /// Each entry has to be a key of the [securityDefinitions] Map.
  final List<String> security;

  /// A map of [SecurityScheme]s that can be used for secure communication.
  final Map<String, SecurityScheme> securityDefinitions;

  /// Indicates the WoT Profile mechanisms followed by this Thing Description
  /// and the corresponding Thing implementation.
  final List<Uri>? profile;

  /// Set of named data schemas.
  ///
  /// To be used in a schema name-value pair inside an
  /// [AdditionalExpectedResponse] object.
  final Map<String, DataSchema>? schemaDefinitions;

  /// URI template variables as defined in [RFC 6570].
  ///
  /// [RFC 6570]: http://tools.ietf.org/html/rfc6570
  final Map<String, Object>? uriVariables;

  /// Additional fields collected during the parsing of a JSON object.
  final Map<String, dynamic>? additionalFields;

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
}

/// Extension for generating [ThingDescription]s from [Map]s more easily.
extension ToThingDescription on Map<String, dynamic> {
  /// Tries to generate a [ThingDescription] from this [Map] object.
  ThingDescription toThingDescription() {
    return ThingDescription.fromJson(this);
  }
}
