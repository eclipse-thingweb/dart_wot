// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

/// Parses a [json] object and adds its contents to a [dataSchema].
void parseDataSchemaJson(DataSchema dataSchema, Map<String, dynamic> json) {
  // TODO(JKRhb): Parse more DataSchema values
  final Object? atType = json["@type"];
  if (atType is String) {
    dataSchema.atType = [atType];
  } else if (atType is List<String>) {
    dataSchema.atType = atType;
  }
}

/// Metadata that describes the data format used. It can be used for validation.
///
/// See W3C WoT Thing Description specification, [section 5.3.2.1][spec link].
///
/// [spec link]: https://w3c.github.io/wot-thing-description/#dataschema
class DataSchema {
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

  /// Creates a new [DataSchema] from a [json] object.
  DataSchema.fromJson(Map<String, dynamic> json) {
    parseDataSchemaJson(this, json);
  }
}
