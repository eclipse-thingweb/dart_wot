// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

/// This [Exception] is thrown when an error within the CoAP Binding occurs.
class CoapBindingException implements Exception {
  final String _message;

  /// Constructor.
  ///
  /// A [_message] can be passed, which will be displayed when the exception is
  /// not caught/propagated.
  CoapBindingException(this._message);

  @override
  String toString() {
    return "$runtimeType: $_message";
  }
}
