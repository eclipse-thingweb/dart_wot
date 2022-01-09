// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import '../core/protocol_interfaces/protocol_client.dart';
import '../core/protocol_interfaces/protocol_client_factory.dart';

import 'coap_client.dart';
import 'coap_config.dart';

/// A [ProtocolClientFactory] that produces CoAP clients.
class CoapClientFactory extends ProtocolClientFactory {
  @override
  final String scheme = "coap";

  /// The [CoapConfig] used to configure new clients.
  final CoapConfig? coapConfig;

  /// Creates a new [CoapClientFactory] based on an optional [CoapConfig].
  CoapClientFactory(this.coapConfig);

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
