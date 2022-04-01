// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../core/protocol_interfaces/protocol_client.dart';
import '../core/protocol_interfaces/protocol_client_factory.dart';

import 'coap_client.dart';
import 'coap_config.dart';

/// A [ProtocolClientFactory] that produces CoAP clients.
class CoapClientFactory extends ProtocolClientFactory {
  @override
  Set<String> get schemes => {"coap", "coaps"};

  /// The [CoapConfig] used to configure new clients.
  final CoapConfig? coapConfig;

  /// Creates a new [CoapClientFactory] based on an optional [CoapConfig].
  CoapClientFactory([this.coapConfig]);

  @override
  bool destroy() {
    // TODO(JKRhb): Check if there is anything to destroy.
    return true;
  }

  @override
  ProtocolClient createClient() => CoapClient(coapConfig);

  @override
  bool init() {
    // TODO(JKRhb): Check if there is anything to init.
    return true;
  }
}
