// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

/// An [Exception] that is thrown when the validation of a definition fails.
class ValidationException implements Exception {
  /// The error message of this [ValidationException].
  final String message;

  /// Constructor.
  ValidationException(this.message);

  @override
  String toString() {
    return "$runtimeType: $message";
  }
}
