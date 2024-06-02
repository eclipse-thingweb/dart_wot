// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:meta/meta.dart";

export "exceptions/web_idl.dart";

/// Base class for custom exceptions defined in `dart_wot`.
@immutable
base class DartWotException implements Exception {
  /// Constructor.
  const DartWotException(this.message);

  /// The error message of this [DartWotException].
  final String message;

  /// The name of this [Exception] that will appear in the error message log.
  String get exceptionType => "DartWotException";

  @override
  String toString() => "$exceptionType: $message";
}

/// Custom [Exception] that is thrown when the discovery process fails.
final class DiscoveryException extends DartWotException {
  /// Creates a new [DiscoveryException] with the specified error [message].
  const DiscoveryException(super.message);

  @override
  String get exceptionType => "DiscoveryException";
}
