// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

/// This [Exception] is thrown when a security-related error occurs in the
/// HTTP binding.
class HttpSecurityException implements Exception {
  /// Constructor.
  HttpSecurityException(this.message);

  /// The error message of this [HttpSecurityException].
  final String message;

  @override
  String toString() {
    return "HttpSecurityException: $message";
  }
}
