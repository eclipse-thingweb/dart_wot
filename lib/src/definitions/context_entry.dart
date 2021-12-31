// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

/// Class holding a [value] and an optional [key] for representing different
/// types of `@context` entries.
class ContextEntry {
  /// The [value] of this [ContextEntry].
  String value;

  /// The [key] of this [ContextEntry]. Might be `null`.
  String? key;

  /// Creates a new [ContextEntry].
  ContextEntry(this.value, this.key);
}
