// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

export "exceptions/web_idl.dart";

/// Base class for custom exceptions defined in `dart_wot`.
base class DartWotException implements Exception {
  /// Constructor.
  DartWotException(this.message);

  /// The error message of this [ValidationException].
  final String message;

  /// The name of this [Exception] that will appear in the error message log.
  final exceptionType = "DartWotException";

  @override
  String toString() => "$exceptionType: $message";
}

/// An [Exception] that is thrown when the validation of a definition fails.
base class ValidationException extends DartWotException {
  /// Constructor.
  ValidationException(super.message, [this._validationErrors]);

  final List<Object>? _validationErrors;

  @override
  String get exceptionType => "ValidationException";

  @override
  String toString() {
    final String formattedValidationErrors;

    final validationErrors = _validationErrors;
    if (validationErrors != null) {
      formattedValidationErrors = [
        "\n\nErrors:\n",
        ...validationErrors,
      ].join("\n");
    } else {
      formattedValidationErrors = "";
    }

    return "$exceptionType: $message$formattedValidationErrors";
  }
}

/// Custom [Exception] that is thrown when the discovery process fails.
final class DiscoveryException extends DartWotException {
  /// Creates a new [DiscoveryException] with the specified error [message].
  DiscoveryException(super.message);

  @override
  String get exceptionType => "DiscoveryException";
}
