// Copyright 2023 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:collection/collection.dart";
import "package:meta/meta.dart";

/// Value corresponding to a WoT DataSchema as specified in [section 7.1]
/// of the [WoT Scripting API] specification.
///
/// [section 7.1]: https://www.w3.org/TR/wot-scripting-api/#the-interactioninput-type
/// [WoT Scripting API]: https://www.w3.org/TR/wot-scripting-api
@immutable
sealed class DataSchemaValue<T> {
  const DataSchemaValue._();

  /// The raw value wrapped by this [DataSchemaValue] object.
  T get value;

  /// Creates a new typed [DataSchemaValue] representing `null`.
  static NullValue fromNull() => const NullValue._create();

  /// Creates a new typed [DataSchemaValue] representing a [String].
  static StringValue fromString(String value) => StringValue._fromValue(value);

  /// Creates a new typed [DataSchemaValue] representing an [int].
  static IntegerValue fromInteger(int value) => IntegerValue._fromValue(value);

  /// Creates a new typed [DataSchemaValue] representing a [num].
  static NumberValue fromNumber(num value) => NumberValue._fromValue(value);

  /// Creates a new typed [DataSchemaValue] representing a [bool]ean [value].
  static BooleanValue fromBoolean(bool value) => BooleanValue._fromValue(value);

  /// Creates a [DataSchemaValue] from a list of [value]s.
  ///
  /// Throws a [FormatException] if any element of the [value] list is not a
  /// valid [DataSchemaValue].
  static ArrayValue fromArray(List<Object?> value) =>
      ArrayValue._fromValue(value);

  /// Creates a [DataSchemaValue] from a map of [value]s.
  ///
  /// Throws a [FormatException] if any entry of the [value] map is not a
  /// valid [DataSchemaValue].
  static ObjectValue fromObject(Map<String, dynamic> value) =>
      ObjectValue._fromValue(value);

  /// Tries to instantiate a [DataSchemaValue] from a raw [value].
  ///
  /// If the [value] is a non-valid data type, the method returns `null`
  /// instead.
  static DataSchemaValue? tryParse(dynamic value) {
    if (value == null) {
      return const NullValue._create();
    }

    if (value is bool) {
      return BooleanValue._fromValue(value);
    }

    if (value is String) {
      return StringValue._fromValue(value);
    }

    if (value is int) {
      return IntegerValue._fromValue(value);
    }

    if (value is double) {
      return NumberValue._fromValue(value);
    }

    if (value is List<Object?>) {
      return ArrayValue.tryParse(value);
    }

    if (value is Map<Object?, Object?>) {
      return ObjectValue.tryParse(value);
    }

    return null;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) =>
      other is DataSchemaValue && value == other.value;

  @override
  String toString() => value.toString();
}

/// A [DataSchemaValue] object that wraps a `null` value.
final class NullValue extends DataSchemaValue<void> {
  const NullValue._create() : super._();

  @override
  void get value {}
}

/// A [DataSchemaValue] object that wraps a [bool].
final class BooleanValue extends DataSchemaValue<bool> {
  /// Instantiates a new [BooleanValue] object from a raw [value].
  const BooleanValue._fromValue(this.value) : super._();

  @override
  final bool value;
}

/// A [DataSchemaValue] object that wraps a [String].
final class StringValue extends DataSchemaValue<String> {
  /// Instantiates a new [StringValue] object from a raw [value].
  const StringValue._fromValue(this.value) : super._();

  @override
  final String value;
}

/// A [DataSchemaValue] object that wraps an [int].
final class IntegerValue extends DataSchemaValue<int> {
  /// Instantiates a new [IntegerValue] object from a raw [value].
  const IntegerValue._fromValue(this.value) : super._();

  @override
  final int value;
}

/// A [DataSchemaValue] object that wraps a [num].
final class NumberValue extends DataSchemaValue<num> {
  /// Instantiates a new [NumberValue] object from a raw [value].
  const NumberValue._fromValue(this.value) : super._();

  @override
  final num value;
}

/// A [DataSchemaValue] object wrapping multiple other [DataSchemaValue]s.
final class ArrayValue extends DataSchemaValue<List<Object?>> {
  /// Instantiates a new [ArrayValue] object from a raw [value].
  const ArrayValue._fromValue(this.value) : super._();

  @override
  final List<Object?> value;

  /// Tries to instantiate a new [ArrayValue] from a raw [value].
  ///
  /// If parsing of at least one input element fails, `null` is returned
  /// instead.
  static ArrayValue? tryParse(List<dynamic> value) {
    final result = <Object?>[];

    for (final entry in value) {
      final arrayValue = DataSchemaValue.tryParse(entry);

      if (arrayValue == null) {
        return null;
      }

      result.add(entry);
    }

    return ArrayValue._fromValue(result);
  }

  @override
  int get hashCode => Object.hashAll(value);

  @override
  bool operator ==(Object other) {
    if (other is! ArrayValue) {
      return false;
    }

    final otherValue = other.value;

    if (value.length != otherValue.length) {
      return false;
    }

    for (final valuePair in IterableZip([value, otherValue])) {
      if (valuePair[0] != valuePair[1]) {
        return false;
      }
    }

    return true;
  }
}

/// A [DataSchemaValue] object wrapping a map of [DataSchemaValue]s.
final class ObjectValue extends DataSchemaValue<Map<String, Object?>> {
  /// Instantiates a new [ObjectValue] object from a raw [value].
  const ObjectValue._fromValue(this.value) : super._();

  @override
  final Map<String, Object?> value;

  /// Tries to instantiate a new [ObjectValue] from a raw [value].
  ///
  /// If parsing of at least one entry fails, `null` is returned instead.
  static ObjectValue? tryParse(Map<Object?, Object?> value) {
    final result = <String, Object?>{};

    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        continue;
      }

      final mapValue = DataSchemaValue.tryParse(entry.value);

      if (mapValue == null) {
        return null;
      }

      result[key] = entry.value;
    }

    return ObjectValue._fromValue(result);
  }

  @override
  int get hashCode {
    final entryList = value.entries.map((entry) => (entry.key, entry.value));

    return Object.hashAll(entryList);
  }

  @override
  bool operator ==(Object other) {
    if (other is! ObjectValue) {
      return false;
    }

    return const DeepCollectionEquality().equals(value, other.value);
  }
}
