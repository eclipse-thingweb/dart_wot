// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:meta/meta.dart';

/// Class holding a [value] and an optional [key] for representing different
/// types of `@context` entries.
@immutable
class ContextEntry {
  /// Creates a new [ContextEntry].
  const ContextEntry(this.value, this.key);

  /// The [value] of this [ContextEntry].
  final String value;

  /// The [key] of this [ContextEntry]. Might be `null`.
  final String? key;

  @override
  bool operator ==(Object? other) {
    return hashCode == other.hashCode;
  }

  @override
  int get hashCode => Object.hash(value, key);
}
