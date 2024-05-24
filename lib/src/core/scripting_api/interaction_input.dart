// Copyright 2023 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:meta/meta.dart";

import "data_schema_value.dart";

/// The (optional) input for an interaction.
///
/// Can be either a [DataSchemaValue] or a byte [Stream].
@immutable
sealed class InteractionInput {
  /// Const constructor for the [InteractionInput] class.
  const InteractionInput();

  /// Creates an [InteractionInput] that represents a [Null] value.
  factory InteractionInput.fromNull() =>
      DataSchemaValueInput(DataSchemaValue.fromNull());

  /// Creates an [InteractionInput] from a [bool]ean [value].
  factory InteractionInput.fromBoolean(bool value) =>
      DataSchemaValueInput(DataSchemaValue.fromBoolean(value));

  /// Creates an [InteractionInput] from an [int]eger [value].
  factory InteractionInput.fromInteger(int value) =>
      DataSchemaValueInput(DataSchemaValue.fromInteger(value));

  /// Creates an [InteractionInput] from a [num]eric [value].
  factory InteractionInput.fromNumber(num value) =>
      DataSchemaValueInput(DataSchemaValue.fromNumber(value));

  /// Creates an [InteractionInput] from a [bool]ean [value].
  factory InteractionInput.fromString(String value) =>
      DataSchemaValueInput(DataSchemaValue.fromString(value));

  /// Creates an [InteractionInput] from a [List] of [value]s.
  ///
  /// Throws a [FormatException] if any element of the [value] list is not a
  /// valid [DataSchemaValue].
  factory InteractionInput.fromArray(List<Object?> value) {
    final dataSchemaValue = ArrayValue.tryParse(value);

    if (dataSchemaValue == null) {
      throw const FormatException("Input contained invalid array element.");
    }

    return DataSchemaValueInput(dataSchemaValue);
  }

  /// Creates an [InteractionInput] from a [Map] of [value]s.
  ///
  /// Throws a [FormatException] if any entry of the [value] map is not a
  /// valid [DataSchemaValue].
  factory InteractionInput.fromObject(Map<String, Object?> value) {
    final dataSchemaValue = ObjectValue.tryParse(value);

    if (dataSchemaValue == null) {
      throw const FormatException("Input contained invalid map entry.");
    }

    return DataSchemaValueInput(dataSchemaValue);
  }

  /// Creates an [InteractionInput] from a byte [stream].
  factory InteractionInput.fromStream(Stream<List<int>> stream) =>
      StreamInput(stream);
}

/// [InteractionInput] variant that wraps a [DataSchemaValue].
final class DataSchemaValueInput extends InteractionInput {
  /// Creates a new [DataSchemaValueInput] from a [dataSchemaValue].
  const DataSchemaValueInput(this.dataSchemaValue);

  /// The data this [DataSchemaValue] wraps.
  final DataSchemaValue dataSchemaValue;

  @override
  int get hashCode => dataSchemaValue.hashCode;

  @override
  bool operator ==(Object other) {
    return other is DataSchemaValueInput &&
        dataSchemaValue == other.dataSchemaValue;
  }
}

/// [InteractionInput] variant that wraps a [byteStream].
final class StreamInput extends InteractionInput {
  /// Creates a new [StreamInput] from a [byteStream].
  const StreamInput(this.byteStream);

  /// The [byteStream] this [StreamInput] wraps.
  final Stream<List<int>> byteStream;
}

/// Extension for simplifying the creation of [DataSchemaValueInput]s from
/// `null` values.
extension NullInteractionInputExtension on Null {
  /// Converts this `null` value into an [InteractionInput].
  InteractionInput asInteractionInput() => InteractionInput.fromNull();
}

/// Extension for simplifying the creation of [DataSchemaValueInput]s from
/// [bool]ean values.
extension BooleanInteractionInputExtension on bool {
  /// Converts this [bool]ean value into an [InteractionInput].
  InteractionInput asInteractionInput() => InteractionInput.fromBoolean(this);
}

/// Extension for simplifying the creation of [DataSchemaValueInput]s from
/// [String] values.
extension StringInteractionInputExtension on String {
  /// Converts this [String] value into an [InteractionInput].
  InteractionInput asInteractionInput() => InteractionInput.fromString(this);
}

/// Extension for simplifying the creation of [DataSchemaValueInput]s from
/// [int] values.
extension IntegerInteractionInputExtension on int {
  /// Converts this [int] value into an [InteractionInput].
  InteractionInput asInteractionInput() => InteractionInput.fromInteger(this);
}

/// Extension for simplifying the creation of [DataSchemaValueInput]s from
/// [num] values.
extension NumberInteractionInputExtension on num {
  /// Converts this [num] value into an [InteractionInput].
  InteractionInput asInteractionInput() => InteractionInput.fromNumber(this);
}

/// Extension for simplifying the creation of [DataSchemaValueInput]s from
/// array values.
extension ArrayInteractionInputExtension on List<Object?> {
  /// Converts this object value into an [InteractionInput].
  InteractionInput asInteractionInput() => InteractionInput.fromArray(this);
}

/// Extension for simplifying the creation of [DataSchemaValueInput]s from
/// object values.
extension ObjectInteractionInputExtension on Map<String, Object?> {
  /// Converts this array value into an [InteractionInput].
  InteractionInput asInteractionInput() => InteractionInput.fromObject(this);
}
