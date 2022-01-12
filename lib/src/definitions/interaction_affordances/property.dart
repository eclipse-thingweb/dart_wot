// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import '../data_schema.dart';
import '../form.dart';
import 'interaction_affordance.dart';

/// Class representing a [Property] Affordance in a Thing Description.
class Property extends InteractionAffordance implements DataSchema {
  @override
  List<String>? atType;

  @override
  Object? constant;

  @override
  Object? defaultValue;

  @override
  List<Object>? enumeration;

  @override
  String? format;

  @override
  List<DataSchema>? oneOf;

  @override
  bool? readOnly;

  @override
  String? type;

  @override
  String? unit;

  @override
  bool? writeOnly;

  /// Default constructor that creates a [Property] from a [List] of [forms].
  Property(List<Form> forms) : super(forms);

  /// Creates a new [Property] from a [json] object.
  Property.fromJson(Map<String, dynamic> json) : super([]) {
    parseAffordanceFields(json);
    parseDataSchemaJson(this, json);
  }
}
