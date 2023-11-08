// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:curie/curie.dart';
import 'package:meta/meta.dart';

import '../data_schema.dart';
import '../extensions/json_parser.dart';
import '../thing_description.dart';
import 'interaction_affordance.dart';

/// Class representing a [Property] Affordance in a Thing Description.
@immutable
class Property extends InteractionAffordance implements DataSchema {
  /// Default constructor that creates a [Property] from a [List] of [forms].
  Property(
    super.thingDescription, {
    super.forms,
    super.uriVariables,
    this.dataSchema,
    this.observable = false,
  });

  /// Creates a new [Property] from a [json] object.
  factory Property.fromJson(
    Map<String, dynamic> json,
    ThingDescription thingDescription,
    PrefixMapping prefixMapping,
  ) {
    final Set<String> parsedFields = {};
    final observable =
        json.parseField<bool>('observable', parsedFields) ?? false;
    final uriVariables =
        json.parseMapField<dynamic>('uriVariables', parsedFields);
    final dataSchema = DataSchema.fromJson(json, prefixMapping, parsedFields);

    final property = Property(
      thingDescription,
      observable: observable,
      dataSchema: dataSchema,
      uriVariables: uriVariables,
    );

    property.forms.addAll(
      json.parseAffordanceForms(
        property,
        prefixMapping,
        parsedFields,
      ),
    );
    property.additionalFields.addAll(
      json.parseAdditionalFields(prefixMapping, parsedFields),
    );

    return property;
  }

  /// The internal [DataSchema] this property is based on.
  final DataSchema? dataSchema;

  @override
  String? get title => dataSchema?.title;

  @override
  Map<String, String>? get titles => dataSchema?.titles;

  @override
  String? get description => dataSchema?.description;

  @override
  Map<String, String>? get descriptions => dataSchema?.descriptions;

  @override
  List<String>? get atType => dataSchema?.atType;

  @override
  Object? get constant => dataSchema?.constant;

  @override
  Object? get defaultValue => dataSchema?.defaultValue;

  @override
  List<Object>? get enumeration => dataSchema?.enumeration;

  @override
  String? get format => dataSchema?.format;

  @override
  List<DataSchema>? get oneOf => dataSchema?.oneOf;

  @override
  bool get readOnly => dataSchema?.readOnly ?? false;

  @override
  String? get type => dataSchema?.type;

  @override
  String? get unit => dataSchema?.unit;

  @override
  bool get writeOnly => dataSchema?.writeOnly ?? false;

  @override
  String? get contentEncoding => dataSchema?.contentEncoding;

  @override
  String? get contentMediaType => dataSchema?.contentMediaType;

  @override
  num? get exclusiveMaximum => dataSchema?.exclusiveMaximum;

  @override
  num? get exclusiveMinimum => dataSchema?.exclusiveMinimum;

  @override
  List<DataSchema>? get items => dataSchema?.items;

  @override
  int? get maxItems => dataSchema?.maxItems;

  @override
  int? get maxLength => dataSchema?.maxLength;

  @override
  num? get maximum => dataSchema?.maximum;

  @override
  int? get minItems => dataSchema?.minItems;

  @override
  int? get minLength => dataSchema?.minItems;

  @override
  num? get minimum => dataSchema?.minimum;

  @override
  num? get multipleOf => dataSchema?.multipleOf;

  @override
  String? get pattern => dataSchema?.pattern;

  @override
  Map<String, DataSchema>? get properties => dataSchema?.properties;

  @override
  List<String>? get required => dataSchema?.required;

  /// A hint that indicates whether Servients hosting the Thing and
  /// Intermediaries should provide a Protocol Binding that supports the
  /// `observeproperty` and `unobserveproperty` operations for this Property.
  final bool observable;

  @override
  Map<String, dynamic>? get rawJson => dataSchema?.rawJson;

  @override
  Map<String, dynamic> get additionalFields =>
      dataSchema?.additionalFields ?? {};
}
