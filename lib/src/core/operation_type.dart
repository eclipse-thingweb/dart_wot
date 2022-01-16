// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

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

  /// Corresponds with the `invokeaction` operation type.
  invokeaction,

  /// Corresponds with the `subscribeevent` operation type.
  subscribeevent,

  /// Corresponds with the `unsubscribeevent` operation type.
  unsubscribeevent,
}
