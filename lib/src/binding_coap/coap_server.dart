// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../core/protocol_interfaces/protocol_server.dart';
import '../core/security_provider.dart';
import '../scripting_api/exposed_thing.dart';
import 'coap_config.dart';

/// A [ProtocolServer] for the Constrained Application Protocol (CoAP).
final class CoapServer implements ProtocolServer {
  /// Creates a new [CoapServer] which can be configured using a [CoapConfig].
  CoapServer([CoapConfig? coapConfig])
      : port = coapConfig?.port ?? 5683,
        preferredBlockSize = coapConfig?.blocksize;

  // TODO(JKRhb): Consider other protocol schemes.
  @override
  final String scheme = 'coap';

  @override
  final int port;

  /// Preferred payload size by the server when using block-wise transfer.
  final int? preferredBlockSize;

  @override
  Future<void> expose(ExposedThing thing) {
    // TODO(JKRhb): implement expose
    throw UnimplementedError();
  }

  @override
  Future<void> start([ServerSecurityCallback? serverSecurityCallback]) {
    // TODO(JKRhb): implement start
    throw UnimplementedError();
  }

  @override
  Future<void> stop() {
    // TODO(JKRhb): implement stop
    throw UnimplementedError();
  }
}
