// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'extensions/json_parser.dart';

/// Parses a [json] object and adds its contents to a [dataSchema].
void parseDataSchemaJson(DataSchema dataSchema, Map<String, dynamic> json) {
  dataSchema
    ..atType = json.parseArrayField<String>('@type')
    ..title = json.parseField<String>('title')
    ..titles = json.parseMapField<String>('titles')
    ..description = json.parseField<String>('description')
    ..constant = json.parseField<Object>('constant')
    ..enumeration = json.parseField<List<Object>>('enum')
    ..readOnly = json.parseField<bool>('readOnly') ?? dataSchema.readOnly
    ..writeOnly = json.parseField<bool>('writeOnly') ?? dataSchema.writeOnly
    ..format = json.parseField<String>('format')
    ..type = json.parseField<String>('type')
    ..minimum = json.parseField<num>('minimum')
    ..exclusiveMinimum = json.parseField<num>('exclusiveMinimum')
    ..maximum = json.parseField<num>('minimum')
    ..exclusiveMaximum = json.parseField<num>('exclusiveMaximum')
    ..multipleOf = json.parseField<num>('multipleOf')
    ..minItems = json.parseField<int>('minItems')
    ..maxItems = json.parseField<int>('maxItems')
    ..required = json.parseField<List<String>>('required')
    ..minLength = json.parseField<int>('minLength')
    ..maxLength = json.parseField<int>('maxLength')
    ..pattern = json.parseField<String>('pattern')
    ..contentEncoding = json.parseField<String>('contentEncoding')
    ..contentMediaType = json.parseField<String>('contentMediaType');

  final oneOf = json['oneOf'];
  if (oneOf is List<Map<String, dynamic>>) {
    dataSchema.oneOf = oneOf.map(DataSchema.fromJson).toList();
  }

  final properties = json['properties'];
  if (properties is Map<String, Map<String, dynamic>>) {
    dataSchema.properties = Map.fromEntries(
      properties.entries.map(
        (entry) => MapEntry(entry.key, DataSchema.fromJson(entry.value)),
      ),
    );
  }
}

/// Metadata that describes the data format used. It can be used for validation.
///
/// See W3C WoT Thing Description specification, [section 5.3.2.1][spec link].
///
/// [spec link]: https://w3c.github.io/wot-thing-description/#dataschema
class DataSchema {
  // TODO: Consider creating separate classes for each data type.
  //       Also see https://github.com/w3c/wot-thing-description/issues/1390

  /// Creates a new [DataSchema] from a [json] object.
  DataSchema.fromJson(Map<String, dynamic> json) {
    parseDataSchemaJson(this, json);
    rawJson = json;
  }

  /// JSON-LD keyword (@type) to label the object with semantic tags (or types).
  List<String>? atType;

  /// The (default) title of this [DataSchema].
  String? title;

  /// A multi-language map of [titles].
  Map<String, String>? titles;

  /// The default [description] of this [DataSchema].
  String? description;

  /// A multi-language map of [descriptions].
  Map<String, String>? descriptions;

  /// A [constant] value.
  Object? constant;

  /// A default value if no actual value is set.
  Object? defaultValue;

  /// The [unit] of the value.
  String? unit;

  /// Allows the specification of multiple [DataSchema]s for validation.
  ///
  /// Data has to be valid against exactly one of these [DataSchema]s.
  List<DataSchema>? oneOf;

  /// Restricted set of values provided as a [List].
  List<Object>? enumeration;

  /// Indicates if a value is read only.
  bool? readOnly;

  /// Indicates if a value is write only.
  bool? writeOnly;

  /// Allows validation based on a format pattern.
  ///
  /// Examples are "date-time", "email", "uri", etc.
  String? format;

  /// JSON-based data type compatible with JSON Schema.
  ///
  /// This value can be one of boolean, integer, number, string, object, array,
  /// or null.
  String? type;

  // Number/Integer fields

  /// Specifies a minimum numeric value, representing an inclusive lower limit.
  ///
  /// Only applicable for associated number or integer types.
  num? minimum;

  /// Specifies a minimum numeric value, representing an exclusive lower limit.
  ///
  /// Only applicable for associated number or integer types.
  num? exclusiveMinimum;

  /// Specifies a maximum numeric value, representing an inclusive upper limit.
  ///
  /// Only applicable for associated number or integer types.
  num? maximum;

  /// Specifies a maximum numeric value, representing an exclusive upper limit.
  ///
  /// Only applicable for associated number or integer types.
  num? exclusiveMaximum;

  /// Specifies the multipleOf value number.
  /// The value must strictly greater than 0.
  ///
  /// Only applicable for associated number or integer types.
  num? multipleOf;

  // Array fields

  /// Used to define the characteristics of an array.
  List<DataSchema>? items;

  /// Defines the minimum number of items that have to be in an array.
  int? minItems;

  /// Defines the maximum number of items that have to be in an array.
  int? maxItems;

  // Object fields

  /// Data schema nested definitions in an `object`.
  Map<String, DataSchema>? properties;

  /// Defines which members of the `object` type are mandatory, i.e. which
  /// members are mandatory in the payload that is to be sent (e.g. input of
  /// invokeaction, writeproperty) and what members will be definitely delivered
  /// in the payload that is being received (e.g. output of invokeaction,
  /// readproperty).
  List<String>? required;

  // String fields

  /// Specifies the minimum length of a string.
  ///
  /// Only applicable for associated string types.
  int? minLength;

  /// Specifies the maximum length of a string.
  ///
  /// Only applicable for associated string types.
  int? maxLength;

  /// Provides a regular expression to express constraints of the string value.
  ///
  /// The regular expression must follow the [ECMA-262] dialect.
  ///
  /// [ECMA-262]: https://tc39.es/ecma262/multipage/
  String? pattern;

  /// Specifies the encoding used to store the contents, as specified in
  /// [RFC 2045] (Section 6.1) and [RFC 4648].
  ///
  /// [RFC 2045]: https://www.rfc-editor.org/rfc/rfc2045
  /// [RFC 4648]: https://www.rfc-editor.org/rfc/rfc4648
  String? contentEncoding;

  /// Specifies the MIME type of the contents of a string value, as described
  /// in [RFC 2046].
  ///
  /// [RFC 2046]: https://www.rfc-editor.org/rfc/rfc2046
  String? contentMediaType;

  /// The original JSON object that was parsed when creating this [DataSchema].
  Map<String, dynamic>? rawJson;
}
