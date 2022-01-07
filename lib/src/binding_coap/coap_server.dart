// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../core/protocol_interfaces/protocol_server.dart';
import '../definitions/credentials/credentials.dart';
import '../scripting_api/exposed_thing.dart';
import 'coap_config.dart';

/// A [ProtocolServer] for the Constrained Application Protocol (CoAP).
class CoapServer extends ProtocolServer {
  // TODO(JKRhb): Consider other protocol schemes.
  @override
  final String scheme = "coap";

  @override
  final int port;

  /// Creates a new [CoapServer] which can be configured using a [CoapConfig].
  CoapServer([CoapConfig? coapConfig]) : port = coapConfig?.port ?? 5683;

  @override
  Future<void> expose(ExposedThing thing) {
    // TODO(JKRhb): implement expose
    throw UnimplementedError();
  }

  @override
  Future<void> start(Map<String, Map<String, Credentials>> credentials) {
    // TODO(JKRhb): implement start
    throw UnimplementedError();
  }

  @override
  Future<void> stop() {
    // TODO(JKRhb): implement stop
    throw UnimplementedError();
  }
}
