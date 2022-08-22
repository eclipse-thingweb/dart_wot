// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:coap/coap.dart';

/// This [Exception] is thrown when an error within the CoAP Binding occurs.
class CoapBindingException implements Exception {
  /// Constructor.
  ///
  /// A [_message] can be passed, which will be displayed when the exception is
  /// not caught/propagated.
  CoapBindingException(this._message);

  final String _message;

  @override
  String toString() {
    return 'CoapBindingException: $_message';
  }
}

/// Base class for [Exception]s that are thrown due to error responses.
abstract class CoapBindingResponseException extends CoapBindingException {
  /// Constructor.
  CoapBindingResponseException(CoapResponse response)
      : super(
          '${response.statusCodeString}. Payload: ${response.payloadString}',
        );
}

/// [Exception] that is thrown if a client error occurs.
class CoapClientErrorException extends CoapBindingResponseException {
  /// Constructor.
  CoapClientErrorException(super.response);

  @override
  String toString() => 'CoapClientErrorException: $_message';
}

/// [Exception] that is thrown if a server error occurs.
class CoapServerErrorException extends CoapBindingResponseException {
  /// Constructor.
  CoapServerErrorException(super.response);

  @override
  String toString() => 'CoapServerErrorException: $_message';
}
