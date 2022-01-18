// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

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
