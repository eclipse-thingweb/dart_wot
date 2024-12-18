// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:curie/curie.dart";

import "../additional_expected_response.dart";
import "../context.dart";
import "../data_schema.dart";
import "../expected_response.dart";
import "../form.dart";
import "../interaction_affordances/interaction_affordance.dart";
import "../link.dart";
import "../operation_type.dart";
import "../security/ace_security_scheme.dart";
import "../security/apikey_security_scheme.dart";
import "../security/auto_security_scheme.dart";
import "../security/basic_security_scheme.dart";
import "../security/bearer_security_scheme.dart";
import "../security/combo_security_scheme.dart";
import "../security/digest_security_scheme.dart";
import "../security/no_security_scheme.dart";
import "../security/oauth2_security_scheme.dart";
import "../security/psk_security_scheme.dart";
import "../security/security_scheme.dart";
import "../version_info.dart";

/// Extension for parsing fields of JSON objects.
extension ParseField on Map<String, dynamic> {
  dynamic _processFieldName(String name, Set<String>? parsedFields) {
    parsedFields?.add(name);
    return this[name];
  }

  /// Parses a single field with a given [name].
  ///
  /// If the field is set, the method ensures that its value is of type [T] and
  /// throws a [FormatException] otherwise.
  /// In case the field is not set, `null` is returned instead, indicating a
  /// missing value.
  ///
  /// If a [Set] of [parsedFields] is passed to this function, the field [name]
  /// will be added to it. This can be used for filtering when parsing
  /// additional fields.
  T? parseField<T>(String name, [Set<String>? parsedFields]) {
    final fieldValue = _processFieldName(name, parsedFields);

    if (!containsKey(name)) {
      return null;
    }

    if (fieldValue is T) {
      return fieldValue;
    }

    if ((T == Map<String, dynamic>) &&
        fieldValue is Map &&
        fieldValue.isEmpty) {
      return <String, dynamic>{} as T;
    }

    throw FormatException(
      "Expected $T, got ${fieldValue.runtimeType} for field $name",
    );
  }

  /// Parses a single field with a given [name] as a [Uri].
  ///
  /// Ensures that the field value is a valid [Uri] and returns `null` if the
  /// value cannot be parsed as such.
  ///
  /// If a [Set] of [parsedFields] is passed to this function, the field [name]
  /// will be added to it. This can be used for filtering when parsing
  /// additional fields.
  Uri? parseUriField(String name, [Set<String>? parsedFields]) {
    final fieldValue = parseField<String>(name, parsedFields);

    if (fieldValue == null) {
      return null;
    }

    return Uri.parse(fieldValue);
  }

  /// Parses a single field with a given [name] as a [List] of [Uri]s.
  ///
  /// Ensures that the field value is either a valid [Uri] or a [List] of [Uri]s
  /// and returns `null` if the value cannot be parsed as such.
  ///
  /// If a [Set] of [parsedFields] is passed to this function, the field [name]
  /// will added. This can be used for filtering when parsing additional fields.
  List<Uri>? parseUriArrayField(
    String name, {
    Set<String>? parsedFields,
    int minimalSize = 0,
  }) {
    final fieldValue = parseArrayField<String>(
      name,
      parsedFields: parsedFields,
      minimalSize: minimalSize,
    );

    if (fieldValue == null) {
      return null;
    }

    final List<Uri> result = [];

    for (final value in fieldValue) {
      final uri = Uri.tryParse(value);
      if (uri != null) {
        result.add(uri);
      }
    }

    return result;
  }

  /// Parses a single field with a given [name] and throws a [FormatException]
  /// if the field should not be set or not be of type [T].
  ///
  /// Like [parseField], it adds the field [name] to the set of [parsedFields],
  /// if present.
  T parseRequiredField<T>(String name, [Set<String>? parsedFields]) {
    final fieldValue = parseField<T>(name, parsedFields);

    if (fieldValue == null) {
      throw FormatException("Required field $name is not set.");
    }

    return fieldValue;
  }

  /// Parses a single field with a given [name] as a [Uri] and throws a
  /// [FormatException] if the field is not present or cannot be parsed.
  ///
  /// If a [Set] of [parsedFields] is passed to this function, the field [name]
  /// will be added. This can be used for filtering when parsing additional
  /// fields.
  Uri parseRequiredUriField(String name, [Set<String>? parsedFields]) {
    final fieldValue = parseRequiredField<String>(name, parsedFields);

    return Uri.parse(fieldValue);
  }

  /// Parses a map field with a given [name].
  ///
  /// Ensures that the field value is of type [T] and returns `null` if the
  /// value does not have this type or is not present.
  ///
  /// If a [Set] of [parsedFields] is passed to this function, the field [name]
  /// will added. This can be used for filtering when parsing additional fields.
  Map<String, T>? parseMapField<T>(String name, [Set<String>? parsedFields]) {
    final fieldValue = _processFieldName(name, parsedFields);

    if (!containsKey(name)) {
      return null;
    }

    if (fieldValue is Map && fieldValue.isEmpty) {
      return {};
    }

    if (fieldValue is Map<String, dynamic>) {
      final Map<String, T> result = {};

      for (final entry in fieldValue.entries) {
        final value = entry.value;

        if (value is T) {
          result[entry.key] = value;
        }
      }

      if (result.length == fieldValue.length) {
        return result;
      }
    }

    throw FormatException(
      "Expected ${Map<String, T>}, got ${fieldValue.runtimeType}",
    );
  }

  /// Parses a field with a given [name] that can contain either a single value
  /// or a list of values of type [T].
  ///
  /// Ensures that the field value is either of type [T] or of type [List<T>],
  /// and throws a [FormatException] otherwise.
  /// If the field is unset, `null` will be returned instead.
  ///
  /// If a [Set] of [parsedFields] is passed to this function, the field [name]
  /// will be added. This can be used for filtering when parsing additional
  /// fields.
  List<T>? parseArrayField<T>(
    String name, {
    Set<String>? parsedFields,
    int minimalSize = 0,
  }) {
    final fieldValue = parseField(name, parsedFields);

    if (fieldValue == null) {
      return null;
    }

    final List<T> result;

    if (fieldValue is List<T>) {
      result = fieldValue;
    } else if (fieldValue is T) {
      result = [fieldValue];
    } else if (fieldValue is List<dynamic>) {
      final filteredArray = fieldValue.whereType<T>().toList(growable: false);

      if (filteredArray.length == fieldValue.length) {
        result = filteredArray;
      } else {
        throw FormatException(
          "Expected $T or a List of $T, but found a List member with invalid "
          "type",
        );
      }
    } else {
      throw FormatException(
        "Expected $T or a List of $T, got ${fieldValue.runtimeType}",
      );
    }

    if (result.length < minimalSize) {
      throw const FormatException(
        "Expected a non-empty array, but encountered an empty one.",
      );
    }

    return result;
  }

  /// Parses a field with a given [name] that can contain either a single value
  /// or a list of values of type [T].
  ///
  /// Ensures that the field value is either of type [T] or of type [List<T>],
  /// and throws a [FormatException] otherwise.
  ///
  /// If a [Set] of [parsedFields] is passed to this function, the field [name]
  /// will be added. This can be used for filtering when parsing additional
  /// fields.
  List<T> parseRequiredArrayField<T>(
    String name, {
    Set<String>? parsedFields,
    int minimalSize = 0,
  }) {
    final result = parseArrayField<T>(
      name,
      parsedFields: parsedFields,
      minimalSize: minimalSize,
    );

    if (result == null) {
      throw FormatException("Missing required field $name");
    }

    return result;
  }

  /// Parses a field with a given [name] as a [DataSchema].
  ///
  /// Returns `null` if the field should not be present or if it is not a JSON
  /// object.
  ///
  /// If a [Set] of [parsedFields] is passed to this function, the field [name]
  /// will added. This can be used for filtering when parsing additional fields.
  DataSchema? parseDataSchemaField(
    String name,
    PrefixMapping prefixMapping,
    Set<String>? parsedFields,
  ) {
    final fieldValue = parseField<Map<String, dynamic>>(name, parsedFields);

    if (fieldValue == null) {
      return null;
    }

    return DataSchema.fromJson(fieldValue, prefixMapping);
  }

  /// Parses a field with a given [name] as a [List] of [DataSchema]s.
  ///
  /// Returns `null` if the field should not be present or if it is not an array
  /// of JSON objects.
  ///
  /// If a [Set] of [parsedFields] is passed to this function, the field [name]
  /// will added. This can be used for filtering when parsing additional fields.
  List<DataSchema>? parseDataSchemaArrayField(
    String name,
    PrefixMapping prefixMapping,
    Set<String>? parsedFields,
  ) {
    final fieldValue =
        parseArrayField<Map<String, dynamic>>(name, parsedFields: parsedFields);

    return fieldValue
        ?.map((e) => DataSchema.fromJson(e, prefixMapping))
        .toList();
  }

  /// Parses a field with a given [name] as a [Map] of [DataSchema]s.
  ///
  /// Returns `null` if the field should not be present and throws a
  /// [FormatException] if it is not a [Map] containing at least a number a
  /// [minimalSize] of other [Map]s.
  ///
  /// If a [Set] of [parsedFields] is passed to this function, the field [name]
  /// will added. This can be used for filtering when parsing additional fields.
  Map<String, DataSchema>? parseDataSchemaMapField(
    String name,
    PrefixMapping prefixMapping,
    Set<String>? parsedFields, {
    int minimalSize = 0,
  }) {
    final fieldValue = parseField<Map<String, dynamic>>(name, parsedFields);

    if (fieldValue == null) {
      return null;
    }

    final length = fieldValue.length;
    if (fieldValue.length < minimalSize) {
      throw FormatException(
          "Expected this Map to contain at least $minimalSize other Map(s), "
          "got $length.");
    }

    final result = <String, DataSchema>{};
    for (final entry in fieldValue.entries) {
      final value = entry.value;

      if (value is Map<String, dynamic>) {
        result[entry.key] = DataSchema.fromJson(value, prefixMapping);
      } else {
        throw FormatException(
          "Expected a Map<String, dynamic>, got ${value.runtimeType}",
        );
      }
    }

    return result;
  }

  /// Parses [Form]s contained in this JSON object.
  ///
  /// Expands compact URIs using the given [prefixMapping] and adds the key
  /// `forms` to the set of [parsedFields], if defined.
  List<Form>? parseForms(
    PrefixMapping prefixMapping,
    Set<String>? parsedFields,
  ) {
    final fieldValue = parseArrayField<Map<String, dynamic>>(
      "forms",
      parsedFields: parsedFields,
      minimalSize: 1,
    );

    return fieldValue
        ?.map(
          (e) => Form.fromJson(
            e,
            prefixMapping,
          ),
        )
        .toList();
  }

  /// Parses [Form]s contained in this JSON object.
  ///
  /// Expands compact URIs using the given [prefixMapping] and adds the key
  /// `forms` to the set of [parsedFields], if defined.
  List<Form> parseAffordanceForms(
    PrefixMapping prefixMapping,
    Set<String>? parsedFields,
  ) {
    final forms = parseForms(
      prefixMapping,
      parsedFields,
    );

    if (forms == null) {
      throw const FormatException(
        'Missing "forms" member in InteractionAffordance',
      );
    }

    return forms;
  }

  /// Parses [Link]s contained in this JSON object.
  ///
  /// Adds the key `links` to the set of [parsedFields], if defined.
  List<Link>? parseLinks(
    PrefixMapping prefixMapping,
    Set<String>? parsedFields,
  ) {
    final fieldValue = parseArrayField<Map<String, dynamic>>(
      "links",
      parsedFields: parsedFields,
    );

    return fieldValue?.map((e) => Link.fromJson(e, prefixMapping)).toList();
  }

  /// Parses [SecurityScheme]s contained in this JSON object.
  ///
  /// Adds the key `securityDefinitions` to the set of [parsedFields], if
  /// defined.
  Map<String, SecurityScheme> parseSecurityDefinitions(
    PrefixMapping prefixMapping,
    Set<String> parsedFields,
  ) {
    final fieldValue =
        parseMapField<dynamic>("securityDefinitions", parsedFields);

    if (fieldValue == null) {
      throw const FormatException("Missing required securityDefinitions field");
    }

    if (fieldValue.isEmpty) {
      throw const FormatException(
        "securityDefinitions has to contain at least one element but is empty.",
      );
    }

    final Map<String, SecurityScheme> result = {};

    for (final securityDefinition in fieldValue.entries) {
      final dynamic value = securityDefinition.value;
      if (value is Map<String, dynamic>) {
        final securityScheme = value._parseSecurityScheme(prefixMapping, {});
        if (securityScheme != null) {
          result[securityDefinition.key] = securityScheme;
        }
      }
    }

    return result;
  }

  SecurityScheme? _parseSecurityScheme(
    PrefixMapping prefixMapping,
    Set<String> parsedFields,
  ) {
    final scheme = parseRequiredField("scheme", parsedFields);

    switch (scheme) {
      case autoSecuritySchemeName:
        return AutoSecurityScheme.fromJson(this, prefixMapping, parsedFields);
      case basicSecuritySchemeName:
        return BasicSecurityScheme.fromJson(this, prefixMapping, parsedFields);
      case bearerSecuritySchemeName:
        return BearerSecurityScheme.fromJson(this, prefixMapping, parsedFields);
      case comboSecuritySchemeName:
        return ComboSecurityScheme.fromJson(this, prefixMapping, parsedFields);
      case nosecSecuritySchemeName:
        return NoSecurityScheme.fromJson(this, prefixMapping, parsedFields);
      case pskSecuritySchemeName:
        return PskSecurityScheme.fromJson(this, prefixMapping, parsedFields);
      case digestSecuritySchemeName:
        return DigestSecurityScheme.fromJson(this, prefixMapping, parsedFields);
      case apiKeySecuritySchemeName:
        return ApiKeySecurityScheme.fromJson(this, prefixMapping, parsedFields);
      case oAuth2SecuritySchemeName:
        return OAuth2SecurityScheme.fromJson(this, prefixMapping, parsedFields);
      case aceSecuritySchemeName:
        return AceSecurityScheme.fromJson(this, prefixMapping, parsedFields);
    }

    return null;
  }

  /// Parses [Property]s contained in this JSON object.
  ///
  /// Adds the key `properties` to the set of [parsedFields], if defined.
  Map<String, Property>? parseProperties(
    PrefixMapping prefixMapping,
    Set<String>? parsedFields,
  ) {
    final fieldValue = parseMapField<dynamic>("properties", parsedFields);

    if (fieldValue == null) {
      return null;
    }

    final Map<String, Property> result = {};

    for (final property in fieldValue.entries) {
      final value = property.value;
      if (value is Map<String, dynamic>) {
        result[property.key] = Property.fromJson(value, prefixMapping);
      }
    }

    return result;
  }

  /// Parses [Action]s contained in this JSON object.
  ///
  /// Adds the key `actions` to the set of [parsedFields], if defined.
  Map<String, Action>? parseActions(
    PrefixMapping prefixMapping,
    Set<String>? parsedFields,
  ) {
    final fieldValue = parseMapField<dynamic>("actions", parsedFields);

    if (fieldValue == null) {
      return null;
    }

    final Map<String, Action> result = {};

    for (final property in fieldValue.entries) {
      final value = property.value;
      if (value is Map<String, dynamic>) {
        result[property.key] = Action.fromJson(value, prefixMapping);
      }
    }

    return result;
  }

  /// Parses [Event]s contained in this JSON object.
  ///
  /// Adds the key `events` to the set of [parsedFields], if defined.
  Map<String, Event>? parseEvents(
    PrefixMapping prefixMapping,
    Set<String>? parsedFields,
  ) {
    final fieldValue = parseMapField<dynamic>("events", parsedFields);

    if (fieldValue == null) {
      return null;
    }

    final Map<String, Event> result = {};

    for (final property in fieldValue.entries) {
      final value = property.value;
      if (value is Map<String, dynamic>) {
        result[property.key] = Event.fromJson(value, prefixMapping);
      }
    }

    return result;
  }

  /// Processes this JSON value and tries to generate a [List] of
  /// [OperationType]s from it.
  List<OperationType>? parseOperationTypes(
    Set<String>? parsedFields, {
    int minimalSize = 0,
  }) {
    final opArray = parseArrayField<String>(
      "op",
      parsedFields: parsedFields,
      minimalSize: minimalSize,
    );

    return opArray?.map(OperationType.fromString).toList();
  }

  /// Parses [ExpectedResponse]s contained in this JSON object.
  ///
  /// Adds the key `events` to the set of [parsedFields], if defined.
  ExpectedResponse? parseExpectedResponse(
    PrefixMapping prefixMapping,
    Set<String>? parsedFields,
  ) {
    final fieldValue = parseMapField<dynamic>("response", parsedFields);

    if (fieldValue == null) {
      return null;
    }

    return ExpectedResponse.fromJson(fieldValue, prefixMapping);
  }

  /// Parses [ExpectedResponse]s contained in this JSON object.
  ///
  /// Adds the key `additionalResponses` to the set of [parsedFields], if
  /// defined.
  List<AdditionalExpectedResponse>? parseAdditionalExpectedResponse(
    PrefixMapping prefixMapping,
    String formContentType,
    Set<String>? parsedFields, {
    int minimalSize = 0,
  }) {
    final fieldValue = parseArrayField<Map<String, dynamic>>(
      "additionalResponses",
      parsedFields: parsedFields,
      minimalSize: minimalSize,
    );

    if (fieldValue == null) {
      return null;
    }

    return fieldValue
        .map(
          (e) => AdditionalExpectedResponse.fromJson(
            e,
            formContentType,
            prefixMapping,
          ),
        )
        .toList();
  }

  /// Parses [VersionInfo]s contained in this JSON object.
  ///
  /// Adds the key `version` to the set of [parsedFields], if defined.
  VersionInfo? parseVersionInfo(
    PrefixMapping prefixMapping,
    Set<String>? parsedFields,
  ) {
    final fieldValue = parseMapField<dynamic>("version", parsedFields);

    if (fieldValue == null) {
      return null;
    }

    return VersionInfo.fromJson(fieldValue, prefixMapping);
  }

  /// Parses a single field with a given [name] as a [DateTime] object.
  ///
  /// Ensures that the field value is a valid [DateTime] and returns `null` if
  /// the value cannot be parsed as such.
  ///
  /// If a [Set] of [parsedFields] is passed to this function, the field [name]
  /// will added. This can be used for filtering when parsing additional fields.
  DateTime? parseDateTime(
    String name,
    Set<String>? parsedFields,
  ) {
    final fieldValue = parseField<String>(name, parsedFields);

    if (fieldValue == null) {
      return null;
    }

    return DateTime.tryParse(fieldValue);
  }

  /// Parses and filters the remaining fields in this JSON object.
  ///
  /// The additional fields are determined by the [Set] of [parsedFields].
  Map<String, dynamic> parseAdditionalFields(
    PrefixMapping prefixMapping,
    Set<String> parsedFields,
  ) {
    return Map.fromEntries(
      entries.where((element) => !parsedFields.contains(element.key)),
    ).map(
      (key, value) => MapEntry(
        _expandCurieKey(key, prefixMapping),
        _expandCurieValue(value, prefixMapping),
      ),
    );
  }

  static String _expandCurieKey(String key, PrefixMapping prefixMapping) {
    if (key.contains(":")) {
      final prefix = key.split(":")[0];
      if (prefixMapping.getPrefixValue(prefix) != null) {
        return prefixMapping.expandCurieString(key);
      }
    }
    return key;
  }

  static dynamic _expandCurieValue(dynamic value, PrefixMapping prefixMapping) {
    if (value is String && value.contains(":")) {
      final prefix = value.split(":")[0];
      if (prefixMapping.getPrefixValue(prefix) != null) {
        return prefixMapping.expandCurieString(value);
      }
    } else if (value is Map<String, dynamic>) {
      return value.map<String, dynamic>((key, dynamic oldValue) {
        final newKey = _expandCurieKey(key, prefixMapping);
        final dynamic newValue = _expandCurieValue(oldValue, prefixMapping);
        return MapEntry<String, dynamic>(newKey, newValue);
      });
    }

    return value;
  }

  /// Parses the JSON-LD `@context` of a TD and returns a [List] of
  /// [ContextEntry]s.
  Context parseContext(Set<String>? parsedFields) {
    final fieldValue = parseField("@context", parsedFields);
    final contextEntries = _parseContextEntries(fieldValue).toList();

    return Context(contextEntries);
  }
}

/// Parses a [List] of `@context` entries from a given [json] value.
Iterable<ContextEntry> _parseContextEntries(dynamic json) sync* {
  switch (json) {
    case final String jsonString:
      {
        yield SingleContextEntry.fromString(jsonString);
      }
    case final List<dynamic> contextEntryList:
      {
        for (final contextEntry in contextEntryList.map(_parseContextEntries)) {
          yield* contextEntry;
        }
      }
    case final Map<String, dynamic> contextEntryList:
      {
        yield* contextEntryList.entries.map((entry) {
          final key = entry.key;
          final value = entry.value;

          if (value is! String) {
            throw FormatException(
                "Expected $value to be a String or a Map<String, String> "
                "as @context entry, got ${value.runtimeType} instead.");
          }

          final uri = Uri.tryParse(value);

          if (!key.startsWith("@") && uri != null) {
            return UriMapContextEntry(key, uri);
          }

          return StringMapContextEntry(key, value);
        });
      }
    default:
      throw FormatException(
        "Expected the @context entry $json to "
        "either be a String or a Map<String, String>, "
        "got ${json.runtimeType} instead.",
      );
  }
}
