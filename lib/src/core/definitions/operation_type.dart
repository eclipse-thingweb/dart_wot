// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "interaction_affordances/interaction_affordance.dart";

/// Enumeration for the possible WoT operation types.
///
/// See W3C WoT Thing Description specification, [section 5.3.4.2.][spec link].
///
/// [spec link]: https://w3c.github.io/wot-thing-description/#td-vocab-op--Form
///
enum OperationType {
  /// Corresponds with the `readproperty` operation type.
  readproperty,

  /// Corresponds with the `writeproperty` operation type.
  writeproperty,

  /// Corresponds with the `observeproperty` operation type.
  observeproperty,

  /// Corresponds with the `unobserveproperty` operation type.
  unobserveproperty,

  /// Corresponds with the `readmultipleproperties` operation type.
  readmultipleproperties,

  /// Corresponds with the `readallproperties` operation type.
  readallproperties,

  /// Corresponds with the `writemultipleproperties` operation type.
  writemultipleproperties,

  /// Corresponds with the `writeallproperties` operation type.
  writeallproperties,

  /// Corresponds with the `invokeaction` operation type.
  invokeaction,

  /// Corresponds with the `subscribeevent` operation type.
  subscribeevent,

  /// Corresponds with the `unsubscribeevent` operation type.
  unsubscribeevent;

  static final Map<String, OperationType> _registry =
      Map.fromEntries(OperationType.values.map((e) => MapEntry(e.name, e)));

  @override
  String toString() => name;

  /// Creates an [OperationType] from a [stringValue].
  static OperationType fromString(String stringValue) {
    final operationType = OperationType._registry[stringValue];

    if (operationType == null) {
      throw FormatException(
        "Encountered unknown OperationType $stringValue.",
      );
    }

    return operationType;
  }

  /// Returns the default operation types for the given [interactionAffordance].
  static List<OperationType> defaultOpValues(
    InteractionAffordance interactionAffordance,
  ) {
    switch (interactionAffordance) {
      case Property(readOnly: final readOnly, writeOnly: final writeOnly):
        return [
          if (!readOnly) OperationType.writeproperty,
          if (!writeOnly) OperationType.readproperty,
        ];
      case Event():
        return [OperationType.subscribeevent, OperationType.unsubscribeevent];

      case Action():
        return [OperationType.invokeaction];
    }
  }
}
