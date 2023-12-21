// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:convert';

import 'package:curie/curie.dart';

import 'additional_expected_response.dart';
import 'data_schema.dart';
import 'extensions/json_parser.dart';
import 'form.dart';
import 'interaction_affordances/action.dart';
import 'interaction_affordances/event.dart';
import 'interaction_affordances/property.dart';
import 'link.dart';
import 'security/security_scheme.dart';
import 'thing_model.dart';
import 'validation/thing_description_schema.dart';
import 'version_info.dart';

/// Type definition for a JSON-LD @context entry.
typedef ContextEntry = ({String? key, String value});

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

  /// Contains the values of the @context for CURIE expansion.
  final prefixMapping = PrefixMapping();

  /// The JSON-LD `@context`, represented by a  [List] of [ContextEntry]s.
  final List<ContextEntry> context = [];

  /// JSON-LD keyword to label the object with semantic tags (or types).
  List<String>? atType = [];

  /// The [id] of this [ThingDescription]. Might be `null`.
  String? id;

  /// The [title] of this [ThingDescription].
  late String title;

  /// A [Map] of multi-language [titles].
  final Map<String, String> titles = {};

  /// The [description] of this [ThingDescription].
  String? description;

  /// A [Map] of multi-language [descriptions].
  final Map<String, String> descriptions = {};

  /// Provides version information.
  VersionInfo? version;

  /// Provides information when the TD instance was created.
  DateTime? created;

  /// Provides information when the TD instance was last modified.
  DateTime? modified;

  /// Provides information about the TD maintainer as URI scheme (e.g., `mailto`
  /// [RFC 6068], `tel` [RFC 3966], `https` [RFC 9112]).
  ///
  /// [RFC 6068]:https://datatracker.ietf.org/doc/html/rfc6068
  /// [RFC 3966]: https://datatracker.ietf.org/doc/html/rfc3966
  /// [RFC 9112]: https://datatracker.ietf.org/doc/html/rfc9112
  Uri? support;

  /// The [base] address of this [ThingDescription]. Might be `null`.
  Uri? base;

  /// A [Map] of [Property] Affordances.
  final Map<String, Property> properties = {};

  /// A [Map] of [Action] Affordances.
  final Map<String, Action> actions = {};

  /// A [Map] of [Event] Affordances.
  final Map<String, Event> events = {};

  /// A [List] of [Link]s.
  final List<Link> links = [];

  /// Set of form hypermedia controls that describe how an operation can be
  /// performed.
  ///
  /// [Form]s are serializations of Protocol Bindings.
  /// Thing-level forms are used to describe endpoints for a group of
  /// interaction affordances.
  final List<Form> forms = [];

  /// A [List] of the [securityDefinitions] that are used as the default.
  ///
  /// Each entry has to be a key of the [securityDefinitions] Map.
  final List<String> security = [];

  /// A map of [SecurityScheme]s that can be used for secure communication.
  final Map<String, SecurityScheme> securityDefinitions = {};

  /// Indicates the WoT Profile mechanisms followed by this Thing Description
  /// and the corresponding Thing implementation.
  final List<Uri> profile = [];

  /// Set of named data schemas.
  ///
  /// To be used in a schema name-value pair inside an
  /// [AdditionalExpectedResponse] object.
  final Map<String, DataSchema> schemaDefinitions = {};

  /// URI template variables as defined in [RFC 6570].
  ///
  /// [RFC 6570]: http://tools.ietf.org/html/rfc6570
  Map<String, Object?>? uriVariables;

  /// Additional fields collected during the parsing of a JSON object.
  final Map<String, dynamic> additionalFields = {};

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
    final Set<String> parsedFields = {};

    context.addAll(json.parseContext(prefixMapping, parsedFields));
    atType = json.parseArrayField('@type', parsedFields);
    title = json.parseRequiredField<String>('title', parsedFields);
    titles.addAll(json.parseMapField<String>('titles', parsedFields) ?? {});
    description = json.parseField<String>('description', parsedFields);
    descriptions
        .addAll(json.parseMapField<String>('descriptions', parsedFields) ?? {});
    version = json.parseVersionInfo(prefixMapping, parsedFields);
    created = json.parseDateTime('created', parsedFields);
    modified = json.parseDateTime('modified', parsedFields);
    support = json.parseUriField('support', parsedFields);
    base = json.parseUriField('base', parsedFields);
    id = json.parseField<String>('id', parsedFields);

    security
        .addAll(json.parseArrayField<String>('security', parsedFields) ?? []);

    securityDefinitions.addAll(
      json.parseSecurityDefinitions(prefixMapping, parsedFields) ?? {},
    );
    forms.addAll(json.parseForms(this, prefixMapping, parsedFields) ?? []);

    properties
        .addAll(json.parseProperties(this, prefixMapping, parsedFields) ?? {});
    actions.addAll(json.parseActions(this, prefixMapping, parsedFields) ?? {});
    events.addAll(json.parseEvents(this, prefixMapping, parsedFields) ?? {});

    links.addAll(json.parseLinks(prefixMapping, parsedFields) ?? []);

    profile.addAll(json.parseUriArrayField('profile', parsedFields) ?? []);
    schemaDefinitions.addAll(
      json.parseDataSchemaMapField(
            'schemaDefinitions',
            prefixMapping,
            parsedFields,
          ) ??
          {},
    );
    uriVariables = json.parseMapField<dynamic>('uriVariables', parsedFields);
    additionalFields
        .addAll(json.parseAdditionalFields(prefixMapping, parsedFields));
  }
}
