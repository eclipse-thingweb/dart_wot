// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

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

  /// Corresponds with the `invokeaction` operation type.
  invokeaction,

  /// Corresponds with the `subscribeevent` operation type.
  subscribeevent,

  /// Corresponds with the `unsubscribeevent` operation type.
  unsubscribeevent,
}

/// Adds a [toShortString] function to the [OperationType] enum.
extension ParseToString on OperationType {
  /// Creates a String representation with the leading "OperationType".
  String toShortString() {
    return toString().split('.').last;
  }
}
