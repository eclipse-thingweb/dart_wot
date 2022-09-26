import 'package:curie/curie.dart';

import '../data_schema.dart';
import '../form.dart';
import '../interaction_affordances/action.dart';
import '../interaction_affordances/event.dart';
import '../interaction_affordances/interaction_affordance.dart';
import '../interaction_affordances/property.dart';
import '../link.dart';
import '../security/security_scheme.dart';
import '../thing_description.dart';
import '../validation/validation_exception.dart';

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
        'Value for field $name has wrong data type or is missing. '
        'Expected ${T.runtimeType}, got ${fieldValue.runtimeType}.',
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
  DataSchema? parseDataSchemaField(String name, [Set<String>? parsedFields]) {
    final fieldValue = parseField(name, parsedFields);

    if (fieldValue is Map<String, dynamic>) {
      return DataSchema.fromJson(fieldValue);
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
    String name, [
    Set<String>? parsedFields,
  ]) {
    final fieldValue = parseField(name, parsedFields);

    if (fieldValue is List<Map<String, dynamic>>) {
      return fieldValue.map(DataSchema.fromJson).toList();
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
    String name, [
    Set<String>? parsedFields,
  ]) {
    final fieldValue = parseField(name, parsedFields);

    if (fieldValue is Map<String, Map<String, dynamic>>) {
      return Map.fromEntries(
        fieldValue.entries.map(
          (entry) => MapEntry(entry.key, DataSchema.fromJson(entry.value)),
        ),
      );
    }

    return null;
  }

  /// Parses [Form]s contained in this JSON object.
  ///
  /// Initializes the [Form] with information from the [interactionAffordance]
  /// and expands compact URIs using the given [prefixMapping].
  ///
  /// Adds the key `forms` to the set of [parsedFields], if defined.
  List<Form> parseForms(
    InteractionAffordance interactionAffordance,
    PrefixMapping prefixMapping, [
    Set<String>? parsedFields,
  ]) {
    final fieldValue = parseField('forms', parsedFields);

    if (fieldValue is! List) {
      throw ValidationException(
        'Missing "forms" member in Intraction Affordance',
      );
    }

    return fieldValue
        .whereType<Map<String, dynamic>>()
        .map((e) => Form.fromJson(e, interactionAffordance))
        .toList();
  }

  /// Parses [Link]s contained in this JSON object.
  ///
  /// Adds the key `links` to the set of [parsedFields], if defined.
  List<Link>? parseLinks(
    PrefixMapping prefixMapping, [
    Set<String>? parsedFields,
  ]) {
    final fieldValue = parseField('links', parsedFields);

    if (fieldValue is! List) {
      return null;
    }

    return fieldValue
        .whereType<Map<String, dynamic>>()
        .map(Link.fromJson)
        .toList();
  }

  /// Parses [SecurityScheme]s contained in this JSON object.
  ///
  /// Adds the key `securityDefinitions` to the set of [parsedFields], if
  /// defined.
  Map<String, SecurityScheme>? parseSecurityDefinitions(
    PrefixMapping prefixMapping, [
    Set<String>? parsedFields,
  ]) {
    final fieldValue =
        parseMapField<dynamic>('securityDefinitions', parsedFields);

    if (fieldValue == null) {
      return null;
    }

    final Map<String, SecurityScheme> result = {};

    for (final securityDefinition in fieldValue.entries) {
      final dynamic value = securityDefinition.value;
      if (value is Map<String, dynamic>) {
        final securityScheme = SecurityScheme.fromJson(value);
        if (securityScheme != null) {
          result[securityDefinition.key] = securityScheme;
        }
      }
    }

    return result;
  }

  /// Parses [Property]s contained in this JSON object.
  ///
  /// Adds the key `properties` to the set of [parsedFields], if defined.
  Map<String, Property>? parseProperties(
    ThingDescription thingDescription,
    PrefixMapping prefixMapping, [
    Set<String>? parsedFields,
  ]) {
    final fieldValue = parseMapField<dynamic>('properties', parsedFields);

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
    PrefixMapping prefixMapping, [
    Set<String>? parsedFields,
  ]) {
    final fieldValue = parseMapField<dynamic>('actions', parsedFields);

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
    PrefixMapping prefixMapping, [
    Set<String>? parsedFields,
  ]) {
    final fieldValue = parseMapField<dynamic>('events', parsedFields);

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
}
