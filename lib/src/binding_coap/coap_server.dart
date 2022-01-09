// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import '../core/credentials.dart';
import '../core/protocol_interfaces/protocol_server.dart';
import '../scripting_api/exposed_thing.dart';
import 'coap_config.dart';

/// A [ProtocolServer] for the Constrained Application Protocol (CoAP).
class CoapServer extends ProtocolServer {
  // TODO(JKRhb): Consider other protocol schemes.
  @override
  String scheme = "coap";

  @override
  int port;

  /// Creates a new [CoapServer] which can be configured using a [CoapConfig].
  CoapServer([CoapConfig? coapConfig]) : port = coapConfig?.port ?? 5683;

  @override
  Future<void> expose(ExposedThing thing) {
    // TODO(JKRhb): implement expose
    throw UnimplementedError();
  }

  @override
  Future<void> start(Map<String, Credentials> credentials) {
    // TODO(JKRhb): implement start
    throw UnimplementedError();
  }

  @override
  Future<void> stop() {
    // TODO(JKRhb): implement stop
    throw UnimplementedError();
  }
}
