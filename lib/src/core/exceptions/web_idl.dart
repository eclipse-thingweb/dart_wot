// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "../exceptions.dart";

/// Corresponds with the Web IDL exception type [TypeError](https://webidl.spec.whatwg.org/#exceptiondef-typeerror).
final class TypeException extends DartWotException {
  /// Instantiates a new [TypeException] with the given [message].
  const TypeException(super.message);

  @override
  String get exceptionType => "TypeException";
}

/// Corresponds with the Web IDL exception type [SecurityError].
///
/// [SecurityError]: https://webidl.spec.whatwg.org/#securityerror
final class SecurityException extends DartWotException {
  /// Instantiates a new [SecurityException] with the given [message].
  const SecurityException(super.message);

  @override
  String get exceptionType => "SecurityException";
}

/// Indicates that a parsing error has occurred.
///
/// Corresponds with the ECMAscript exception type [SyntaxError].
///
/// [SyntaxError]: https://tc39.es/ecma262/multipage/fundamental-objects.html#sec-native-error-types-used-in-this-standard-syntaxerror
final class SyntaxException extends DartWotException {
  /// Instantiates a new [SyntaxException] with the given [message].
  const SyntaxException(super.message);

  @override
  String get exceptionType => "SyntaxException";
}

/// Indicates that an operation is not supported.
///
/// Corresponds with the Web IDL exception type [NotSupportedError].
///
/// [NotSupportedError]: https://webidl.spec.whatwg.org/#notsupportederror
final class NotSupportedException extends DartWotException {
  /// Instantiates a new [NotSupportedException] with the given [message].
  const NotSupportedException(super.message);

  @override
  String get exceptionType => "NotSupportedException";
}

/// Indicates that an operation failed for an operation-specific reason.
///
/// Corresponds with the Web IDL exception type [OperationError].
///
/// [OperationError]: https://webidl.spec.whatwg.org/#operationerror
final class OperationException extends DartWotException {
  /// Instantiates a new [OperationException] with the given [message].
  const OperationException(super.message);

  @override
  String get exceptionType => "OperationException";
}

/// Indicates that an I/O read operation failed.
///
/// Corresponds with the Web IDL exception type [NotReadableError].
///
/// [NotReadableError]: https://webidl.spec.whatwg.org/#notreadableerror
final class NotReadableException extends DartWotException {
  /// Instantiates a new [NotReadableException] with the given [message].
  const NotReadableException(super.message);

  @override
  String get exceptionType => "NotReadableException";
}

/// Simple exception indicating that an index is out of range.
///
/// Corresponds with the Web IDL exception type [RangeError].
///
/// [RangeError]: https://webidl.spec.whatwg.org/#exceptiondef-rangeerror
final class RangeExeption extends DartWotException {
  /// Instantiates a new [RangeExeption] with the given [message].
  const RangeExeption(super.message);

  @override
  String get exceptionType => "RangeExeption";
}

/// Exception indicating that a request is not allowed by the user agent or the
/// platform in the current context, possibly because the user denied
/// permission.
///
/// Corresponds with the Web IDL exception type [NotAllowedError].
///
/// [NotAllowedError]: https://webidl.spec.whatwg.org/#notallowederror
final class NotFoundExeption extends DartWotException {
  /// Instantiates a new [NotFoundExeption] with the given [message].
  const NotFoundExeption(super.message);

  @override
  String get exceptionType => "NotFoundExeption";
}

/// Exception indicating that a network error occurred.
///
/// Corresponds with the Web IDL exception type [NetworkError].
///
/// [NetworkError]: https://webidl.spec.whatwg.org/#networkerror
final class NetworkExeption extends DartWotException {
  /// Instantiates a new [NetworkExeption] with the given [message].
  const NetworkExeption(super.message);

  @override
  String get exceptionType => "NetworkExeption";
}
