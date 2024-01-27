// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "../exceptions.dart";

/// Indicates that an I/O read operation failed.
///
/// Corresponds with the Web IDL exception type [NotReadableError].
///
/// [NotReadableError]: https://webidl.spec.whatwg.org/#notreadableerror
final class NotReadableException extends DartWotException {
  /// Instantiates a new [NotReadableException] with the given [message].
  NotReadableException(super.message);

  @override
  String get exceptionType => "NotReadableException";
}
