import "package:collection/collection.dart";
import "package:curie/curie.dart";

import "../additional_expected_response.dart";
import "../data_schema.dart";
import "../expected_response.dart";
import "../form.dart";
import "../interaction_affordances/action.dart";
import "../interaction_affordances/event.dart";
import "../interaction_affordances/interaction_affordance.dart";
import "../interaction_affordances/property.dart";
import "../link.dart";
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
import "../thing_description.dart";
import "../validation/validation_exception.dart";
import "../version_info.dart";

const _validTdContextValues = [
  "https://www.w3.org/2019/wot/td/v1",
  "https://www.w3.org/2022/wot/td/v1.1",
  "http://www.w3.org/ns/td",
];

/// Extension for parsing fields of JSON objects.
extension ParseField on Map<String, dynamic> {
  dynamic _processFieldName(String name, Set<String>? parsedFields) {
    parsedFields?.add(name);
    return this[name];
  }

  /// Parses a single field with a given [name].
  ///
  /// Ensures that the field value is of type [T] and returns `null` if the
  /// value does not have this type or is not present.
  ///
  /// If a [Set] of [parsedFields] is passed to this function, the field [name]
  /// will added. This can be used for filtering when parsing additional fields.
  T? parseField<T>(String name, [Set<String>? parsedFields]) {
    final fieldValue = _processFieldName(name, parsedFields);

    if (fieldValue is T) {
      return fieldValue;
    }

    return null;
  }

  /// Parses a single field with a given [name] as a [Uri].
  ///
  /// Ensures that the field value is a valid [Uri] and returns `null` if the
  /// value cannot be parsed as such.
  ///
  /// If a [Set] of [parsedFields] is passed to this function, the field [name]
  /// will added. This can be used for filtering when parsing additional fields.
  Uri? parseUriField(String name, [Set<String>? parsedFields]) {
    final fieldValue = parseField<String>(name, parsedFields);

    if (fieldValue == null) {
      return null;
    }

    return Uri.tryParse(fieldValue);
  }

  /// Parses a single field with a given [name] as a [List] of [Uri]s.
  ///
  /// Ensures that the field value is either a valid [Uri] or a [List] of [Uri]s
  /// and returns `null` if the value cannot be parsed as such.
  ///
  /// If a [Set] of [parsedFields] is passed to this function, the field [name]
  /// will added. This can be used for filtering when parsing additional fields.
  List<Uri>? parseUriArrayField(String name, [Set<String>? parsedFields]) {
    final fieldValue = parseArrayField<String>(name, parsedFields);

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

  /// Parses a single field with a given [name] and throws a
  /// [ValidationException] if the field is not present or does not have the
  /// type [T].
  ///
  /// Like [parseField], it adds the field [name] to the set of [parsedFields],
  /// if present.
  T parseRequiredField<T>(String name, [Set<String>? parsedFields]) {
    final fieldValue = parseField(name, parsedFields);

    if (fieldValue is! T) {
      throw ValidationException(
        "Value for field $name has wrong data type or is missing. "
        "Expected ${T.runtimeType}, got ${fieldValue.runtimeType}.",
      );
    }

    return fieldValue;
  }

  /// Parses a single field with a given [name] as a [Uri] and throws a
  /// [ValidationException] if the field is not present or cannot be parsed.
  ///
  /// If a [Set] of [parsedFields] is passed to this function, the field [name]
  /// will added. This can be used for filtering when parsing additional fields.
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

    if (fieldValue is Map<String, dynamic>) {
      final Map<String, T> result = {};

      for (final entry in fieldValue.entries) {
        final value = entry.value;
        if (value is T) {
          result[entry.key] = value;
        }
      }

      return result;
    }
    return null;
  }

  /// Parses a field with a given [name] that can contain either a single value
  /// or a list of values of type [T].
  ///
  /// Ensures that the field value is of type [T] or `List<T>` and returns
  /// `null` if the value does not have one of these types or is not present.
  ///
  /// If a [Set] of [parsedFields] is passed to this function, the field [name]
  /// will added. This can be used for filtering when parsing additional fields.
  List<T>? parseArrayField<T>(String name, [Set<String>? parsedFields]) {
    final fieldValue = parseField(name, parsedFields);

    if (fieldValue is T) {
      return [fieldValue];
    } else if (fieldValue is List<dynamic>) {
      return fieldValue.whereType<T>().toList(growable: false);
    }

    return null;
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
    final fieldValue = parseField(name, parsedFields);

    if (fieldValue is Map<String, dynamic>) {
      return DataSchema.fromJson(fieldValue, prefixMapping);
    }

    return null;
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
    final fieldValue = parseField(name, parsedFields);

    if (fieldValue is List<Map<String, dynamic>>) {
      return fieldValue
          .map((e) => DataSchema.fromJson(e, prefixMapping))
          .toList();
    }

    return null;
  }

  /// Parses a field with a given [name] as a [Map] of [DataSchema]s.
  ///
  /// Returns `null` if the field should not be present or if it is not a
  /// JSON object contaning other objects.
  ///
  /// If a [Set] of [parsedFields] is passed to this function, the field [name]
  /// will added. This can be used for filtering when parsing additional fields.
  Map<String, DataSchema>? parseDataSchemaMapField(
    String name,
    PrefixMapping prefixMapping,
    Set<String>? parsedFields,
  ) {
    final fieldValue = parseField(name, parsedFields);

    if (fieldValue is Map<String, Map<String, dynamic>>) {
      return Map.fromEntries(
        fieldValue.entries.map(
          (entry) => MapEntry(
            entry.key,
            DataSchema.fromJson(entry.value, prefixMapping),
          ),
        ),
      );
    }

    return null;
  }

  /// Parses [Form]s contained in this JSON object.
  ///
  /// Initializes the [Form] with information from the [thingDescription]
  /// and expands compact URIs using the given [prefixMapping].
  ///
  /// Adds the key `forms` to the set of [parsedFields], if defined.
  List<Form>? parseForms(
    ThingDescription thingDescription,
    PrefixMapping prefixMapping,
    Set<String>? parsedFields, [
    InteractionAffordance? interactionAffordance,
  ]) {
    final fieldValue = parseField("forms", parsedFields);

    if (fieldValue is! List) {
      return null;
    }

    return fieldValue
        .whereType<Map<String, dynamic>>()
        .map(
          (e) => Form.fromJson(
            e,
            prefixMapping,
            thingDescription,
            interactionAffordance,
          ),
        )
        .toList();
  }

  /// Parses [Form]s contained in this JSON object for an
  /// [interactionAffordance].
  ///
  /// Initializes the [Form] with information from the [interactionAffordance]
  /// and expands compact URIs using the given [prefixMapping].
  ///
  /// Adds the key `forms` to the set of [parsedFields], if defined.
  List<Form> parseAffordanceForms(
    InteractionAffordance interactionAffordance,
    PrefixMapping prefixMapping,
    Set<String>? parsedFields,
  ) {
    final forms = parseForms(
      interactionAffordance.thingDescription,
      prefixMapping,
      parsedFields,
      interactionAffordance,
    );

    if (forms != null) {
      return forms;
    }

    throw ValidationException(
      'Missing "forms" member in Intraction Affordance',
    );
  }

  /// Parses [Link]s contained in this JSON object.
  ///
  /// Adds the key `links` to the set of [parsedFields], if defined.
  List<Link>? parseLinks(
    PrefixMapping prefixMapping,
    Set<String>? parsedFields,
  ) {
    final fieldValue = parseField("links", parsedFields);

    if (fieldValue is! List) {
      return null;
    }

    return fieldValue
        .whereType<Map<String, dynamic>>()
        .map((e) => Link.fromJson(e, prefixMapping))
        .toList();
  }

  /// Parses [SecurityScheme]s contained in this JSON object.
  ///
  /// Adds the key `securityDefinitions` to the set of [parsedFields], if
  /// defined.
  Map<String, SecurityScheme>? parseSecurityDefinitions(
    PrefixMapping prefixMapping,
    Set<String> parsedFields,
  ) {
    final fieldValue =
        parseMapField<dynamic>("securityDefinitions", parsedFields);

    if (fieldValue == null) {
      return null;
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
      case "auto":
        return AutoSecurityScheme.fromJson(this, prefixMapping, parsedFields);
      case "basic":
        return BasicSecurityScheme.fromJson(this, prefixMapping, parsedFields);
      case "bearer":
        return BearerSecurityScheme.fromJson(this, prefixMapping, parsedFields);
      case "combo":
        return ComboSecurityScheme.fromJson(this, prefixMapping, parsedFields);
      case "nosec":
        return NoSecurityScheme.fromJson(this, prefixMapping, parsedFields);
      case "psk":
        return PskSecurityScheme.fromJson(this, prefixMapping, parsedFields);
      case "digest":
        return DigestSecurityScheme.fromJson(this, prefixMapping, parsedFields);
      case "apikey":
        return ApiKeySecurityScheme.fromJson(this, prefixMapping, parsedFields);
      case "oauth2":
        return OAuth2SecurityScheme.fromJson(this, prefixMapping, parsedFields);
      case "ace:ACESecurityScheme":
        return AceSecurityScheme.fromJson(this, prefixMapping, parsedFields);
    }

    return null;
  }

  /// Parses [Property]s contained in this JSON object.
  ///
  /// Adds the key `properties` to the set of [parsedFields], if defined.
  Map<String, Property>? parseProperties(
    ThingDescription thingDescription,
    PrefixMapping prefixMapping,
    Set<String>? parsedFields,
  ) {
    final fieldValue = parseMapField<dynamic>("properties", parsedFields);

    if (fieldValue == null) {
      return null;
    }

    final Map<String, Property> result = {};

    for (final property in fieldValue.entries) {
      final dynamic value = property.value;
      if (value is Map<String, dynamic>) {
        result[property.key] =
            Property.fromJson(value, thingDescription, prefixMapping);
      }
    }

    return result;
  }

  /// Parses [Action]s contained in this JSON object.
  ///
  /// Adds the key `actions` to the set of [parsedFields], if defined.
  Map<String, Action>? parseActions(
    ThingDescription thingDescription,
    PrefixMapping prefixMapping,
    Set<String>? parsedFields,
  ) {
    final fieldValue = parseMapField<dynamic>("actions", parsedFields);

    if (fieldValue == null) {
      return null;
    }

    final Map<String, Action> result = {};

    for (final property in fieldValue.entries) {
      final dynamic value = property.value;
      if (value is Map<String, dynamic>) {
        result[property.key] =
            Action.fromJson(value, thingDescription, prefixMapping);
      }
    }

    return result;
  }

  /// Parses [Event]s contained in this JSON object.
  ///
  /// Adds the key `events` to the set of [parsedFields], if defined.
  Map<String, Event>? parseEvents(
    ThingDescription thingDescription,
    PrefixMapping prefixMapping,
    Set<String>? parsedFields,
  ) {
    final fieldValue = parseMapField<dynamic>("events", parsedFields);

    if (fieldValue == null) {
      return null;
    }

    final Map<String, Event> result = {};

    for (final property in fieldValue.entries) {
      final dynamic value = property.value;
      if (value is Map<String, dynamic>) {
        result[property.key] =
            Event.fromJson(value, thingDescription, prefixMapping);
      }
    }

    return result;
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
    Set<String>? parsedFields,
  ) {
    final fieldValue = parseArrayField<Map<String, dynamic>>(
      "additionalResponses",
      parsedFields,
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

  /// Parses the JSON-LD @context of a TD and returns a [List] of
  /// [ContextEntry]s.
  List<ContextEntry> parseContext(
    PrefixMapping prefixMapping,
    Set<String>? parsedFields, {
    bool firstEntry = true,
  }) {
    final fieldValue = parseField("@context", parsedFields);

    return _parseContext(fieldValue, prefixMapping);
  }
}

/// Parses a [List] of `@context` entries from a given [json] value.
///
/// `@context` extensions are added to the provided [prefixMapping].
/// If a given entry is the [firstEntry], it will be set in the
/// [prefixMapping] accordingly.
List<ContextEntry> _parseContext(
  dynamic json,
  PrefixMapping prefixMapping, {
  bool firstEntry = true,
}) {
  switch (json) {
    case final String jsonString:
      {
        if (firstEntry && _validTdContextValues.contains(jsonString)) {
          prefixMapping.defaultPrefixValue = jsonString;
        }
        return [(key: null, value: jsonString)];
      }
    case final List<dynamic> contextList:
      {
        final List<ContextEntry> result = [];
        contextList
            .mapIndexed(
              (index, contextEntry) => _parseContext(
                contextEntry,
                prefixMapping,
                firstEntry: index == 0,
              ),
            )
            .forEach(result.addAll);
        return result;
      }
    case final Map<String, dynamic> contextList:
      {
        return contextList.entries.map((entry) {
          final key = entry.key;
          final value = entry.value;

          if (value is! String) {
            throw ContextValidationException(value.runtimeType);
          }

          if (!key.startsWith("@") && Uri.tryParse(value) != null) {
            prefixMapping.addPrefix(key, value);
          }
          return (key: key, value: value);
        }).toList();
      }
  }

  throw ContextValidationException(json.runtimeType);
}

/// Custom [ValidationException] that is thrown for an invalid [ContextEntry].
class ContextValidationException extends ValidationException {
  /// Creates a new [ContextValidationException] indicating the invalid
  /// [runtimeType].
  ContextValidationException(Type runtimeType)
      : super(
          "Excepted either a String or a Map<String, String> "
          "as @context entry, got $runtimeType instead.",
        );
}
