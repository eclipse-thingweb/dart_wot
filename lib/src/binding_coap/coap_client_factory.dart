// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "../../core.dart";

import "coap_client.dart";
import "coap_config.dart";
import "coap_definitions.dart";

/// A [ProtocolClientFactory] that produces CoAP clients.
final class CoapClientFactory implements ProtocolClientFactory {
  /// Creates a new [CoapClientFactory] based on an optional [CoapConfig].
  CoapClientFactory({
    this.coapConfig,
    ClientPskCallback? pskCredentialsCallback,
    AceSecurityCallback? aceSecurityCallback,
  })  : _pskCredentialsCallback = pskCredentialsCallback,
        _aceSecurityCallback = aceSecurityCallback;

  /// The [CoapConfig] used to configure new clients.
  final CoapConfig? coapConfig;

  final ClientPskCallback? _pskCredentialsCallback;

  final AceSecurityCallback? _aceSecurityCallback;

  @override
  Set<String> get schemes => {"coap", "coaps"};

  @override
  bool destroy() {
    return true;
  }

  @override
  ProtocolClient createClient() => CoapClient(
        coapConfig: coapConfig,
        pskCredentialsCallback: _pskCredentialsCallback,
        aceSecurityCallback: _aceSecurityCallback,
      );

  @override
  bool init() {
    return true;
  }

  @override
  bool supportsOperation(OperationType operationType, String? subprotocol) {
    const observeOperations = [
      OperationType.observeproperty,
      OperationType.unobserveproperty,
      OperationType.subscribeevent,
      OperationType.unsubscribeevent,
    ];

    if (observeOperations.contains(operationType)) {
      return CoapSubprotocol.tryParse(subprotocol ?? "") ==
          CoapSubprotocol.observe;
    }

    return subprotocol == null;
  }
}
