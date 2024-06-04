// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:curie/curie.dart";
import "package:meta/meta.dart";

import "extensions/json_parser.dart";
import "extensions/json_serializer.dart";
import "extensions/serializable.dart";

/// Metadata that describes the data format used. It can be used for validation.
///
/// See W3C WoT Thing Description specification, [section 5.3.2.1][spec link].
///
/// [spec link]: https://w3c.github.io/wot-thing-description/#dataschema
@immutable
class DataSchema implements Serializable {
  /// Constructor
  const DataSchema({
    this.atType,
    this.title,
    this.titles,
    this.description,
    this.descriptions,
    this.constant,
    this.defaultValue,
    this.unit,
    this.oneOf,
    this.enumeration,
    this.readOnly = false,
    this.writeOnly = false,
    this.format,
    this.type,
    this.minimum,
    this.exclusiveMinimum,
    this.maximum,
    this.exclusiveMaximum,
    this.multipleOf,
    this.items,
    this.minItems,
    this.maxItems,
    this.properties,
    this.required,
    this.minLength,
    this.maxLength,
    this.pattern,
    this.contentEncoding,
    this.contentMediaType,
    this.additionalFields = const {},
  });

  // TODO: Consider creating separate classes for each data type.
  //       Also see https://github.com/w3c/wot-thing-description/issues/1390

  /// Creates a new [DataSchema] from a [json] object.
  factory DataSchema.fromJson(
    Map<String, dynamic> json,
    PrefixMapping prefixMapping, [
    Set<String>? parsedFields,
  ]) {
    parsedFields = parsedFields ?? {};
    final atType =
        json.parseArrayField<String>("@type", parsedFields: parsedFields);
    final title = json.parseField<String>("title", parsedFields);
    final titles = json.parseMapField<String>("titles", parsedFields);
    final description = json.parseField<String>("description", parsedFields);
    final descriptions =
        json.parseMapField<String>("descriptions", parsedFields);
    final constant = json.parseField<Object>("constant", parsedFields);
    final defaultValue = json.parseField<Object>("default", parsedFields);
    final enumeration = json.parseArrayField<Object?>(
      "enum",
      parsedFields: parsedFields,
      minimalSize: 1,
    );
    final readOnly = json.parseField<bool>("readOnly", parsedFields);
    final writeOnly = json.parseField<bool>("writeOnly", parsedFields);
    final format = json.parseField<String>("format", parsedFields);
    final unit = json.parseField<String>("unit", parsedFields);
    final type = json.parseField<String>("type", parsedFields);
    final minimum = json.parseField<num>("minimum", parsedFields);
    final exclusiveMinimum =
        json.parseField<num>("exclusiveMinimum", parsedFields);
    final maximum = json.parseField<num>("maximum", parsedFields);
    final exclusiveMaximum =
        json.parseField<num>("exclusiveMaximum", parsedFields);
    final multipleOf = json.parseField<num>("multipleOf", parsedFields);
    final items =
        json.parseDataSchemaArrayField("items", prefixMapping, parsedFields);
    final minItems = json.parseField<int>("minItems", parsedFields);
    final maxItems = json.parseField<int>("maxItems", parsedFields);
    final required = json.parseField<List<String>>("required", parsedFields);
    final minLength = json.parseField<int>("minLength", parsedFields);
    final maxLength = json.parseField<int>("maxLength", parsedFields);
    final pattern = json.parseField<String>("pattern", parsedFields);
    final contentEncoding =
        json.parseField<String>("contentEncoding", parsedFields);
    final contentMediaType =
        json.parseField<String>("contentMediaType", parsedFields);
    final oneOf =
        json.parseDataSchemaArrayField("oneOf", prefixMapping, parsedFields);
    final properties =
        json.parseDataSchemaMapField("properties", prefixMapping, parsedFields);
    final additionalFields =
        json.parseAdditionalFields(prefixMapping, parsedFields);

    return DataSchema(
      atType: atType,
      title: title,
      titles: titles,
      description: description,
      descriptions: descriptions,
      constant: constant,
      defaultValue: defaultValue,
      enumeration: enumeration,
      readOnly: readOnly,
      writeOnly: writeOnly,
      format: format,
      unit: unit,
      type: type,
      minimum: minimum,
      exclusiveMinimum: exclusiveMinimum,
      maximum: maximum,
      exclusiveMaximum: exclusiveMaximum,
      multipleOf: multipleOf,
      items: items,
      minItems: minItems,
      maxItems: maxItems,
      required: required,
      minLength: minLength,
      maxLength: maxLength,
      pattern: pattern,
      contentEncoding: contentEncoding,
      contentMediaType: contentMediaType,
      oneOf: oneOf,
      properties: properties,
      additionalFields: additionalFields,
    );
  }

  /// JSON-LD keyword (@type) to label the object with semantic tags (or types).
  final List<String>? atType;

  /// The (default) title of this [DataSchema].
  final String? title;

  /// A multi-language map of [titles].
  final Map<String, String>? titles;

  /// The default [description] of this [DataSchema].
  final String? description;

  /// A multi-language map of [descriptions].
  final Map<String, String>? descriptions;

  /// A [constant] value.
  final Object? constant;

  /// A default value if no actual value is set.
  final Object? defaultValue;

  /// The [unit] of the value.
  final String? unit;

  /// Allows the specification of multiple [DataSchema]s for validation.
  ///
  /// Data has to be valid against exactly one of these [DataSchema]s.
  final List<DataSchema>? oneOf;

  /// Restricted set of values provided as a [List].
  final List<Object?>? enumeration;

  /// Indicates if a value is read only.
  final bool? readOnly;

  /// Indicates if a value is write only.
  final bool? writeOnly;

  /// Allows validation based on a format pattern.
  ///
  /// Examples are "date-time", "email", "uri", etc.
  final String? format;

  /// JSON-based data type compatible with JSON Schema.
  ///
  /// This value can be one of boolean, integer, number, string, object, array,
  /// or null.
  final String? type;

  // Number/Integer fields

  /// Specifies a minimum numeric value, representing an inclusive lower limit.
  ///
  /// Only applicable for associated number or integer types.
  final num? minimum;

  /// Specifies a minimum numeric value, representing an exclusive lower limit.
  ///
  /// Only applicable for associated number or integer types.
  final num? exclusiveMinimum;

  /// Specifies a maximum numeric value, representing an inclusive upper limit.
  ///
  /// Only applicable for associated number or integer types.
  final num? maximum;

  /// Specifies a maximum numeric value, representing an exclusive upper limit.
  ///
  /// Only applicable for associated number or integer types.
  final num? exclusiveMaximum;

  /// Specifies the multipleOf value number.
  /// The value must strictly greater than 0.
  ///
  /// Only applicable for associated number or integer types.
  final num? multipleOf;

  // Array fields

  /// Used to define the characteristics of an array.
  final List<DataSchema>? items;

  /// Defines the minimum number of items that have to be in an array.
  final int? minItems;

  /// Defines the maximum number of items that have to be in an array.
  final int? maxItems;

  // Object fields

  /// Data schema nested definitions in an `object`.
  final Map<String, DataSchema>? properties;

  /// Defines which members of the `object` type are mandatory, i.e. which
  /// members are mandatory in the payload that is to be sent (e.g. input of
  /// invokeaction, writeproperty) and what members will be definitely delivered
  /// in the payload that is being received (e.g. output of invokeaction,
  /// readproperty).
  final List<String>? required;

  // String fields

  /// Specifies the minimum length of a string.
  ///
  /// Only applicable for associated string types.
  final int? minLength;

  /// Specifies the maximum length of a string.
  ///
  /// Only applicable for associated string types.
  final int? maxLength;

  /// Provides a regular expression to express constraints of the string value.
  ///
  /// The regular expression must follow the [ECMA-262] dialect.
  ///
  /// [ECMA-262]: https://tc39.es/ecma262/multipage/
  final String? pattern;

  /// Specifies the encoding used to store the contents, as specified in
  /// [RFC 2045] (Section 6.1) and [RFC 4648].
  ///
  /// [RFC 2045]: https://www.rfc-editor.org/rfc/rfc2045
  /// [RFC 4648]: https://www.rfc-editor.org/rfc/rfc4648
  final String? contentEncoding;

  /// Specifies the MIME type of the contents of a string value, as described
  /// in [RFC 2046].
  ///
  /// [RFC 2046]: https://www.rfc-editor.org/rfc/rfc2046
  final String? contentMediaType;

  /// Additional fields that could not be deserialized as class members.
  final Map<String, dynamic> additionalFields;

  @override
  Map<String, dynamic> toJson() {
    final result = {
      ...additionalFields,
    };

    final keyValuePairs = [
      ("@type", atType),
      ("title", title),
      ("titles", titles),
      ("description", description),
      ("descriptions", descriptions),
      ("const", constant),
      ("default", defaultValue),
      ("enum", enumeration),
      ("readOnly", readOnly),
      ("writeOnly", writeOnly),
      ("format", format),
      ("unit", unit),
      ("type", type),
      ("minimum", minimum),
      ("exclusiveMinimum", exclusiveMinimum),
      ("maximum", maximum),
      ("exclusiveMaximum", exclusiveMaximum),
      ("multipleOf", multipleOf),
      ("items", items),
      ("minItems", minItems),
      ("maxItems", maxItems),
      ("required", required),
      ("minLength", minLength),
      ("maxLength", maxLength),
      ("pattern", pattern),
      ("contentEncoding", contentEncoding),
      ("contentMediaType", contentMediaType),
      ("oneOf", oneOf),
      ("properties", properties),
    ];

    for (final (key, value) in keyValuePairs) {
      final dynamic convertedValue;

      switch (value) {
        case null:
          continue;
        case List<Serializable>():
          convertedValue = value.toJson();
        case Map<String, Serializable>():
          convertedValue = value.toJson();
        default:
          convertedValue = value;
      }

      result[key] = convertedValue;
    }

    return result;
  }
}
