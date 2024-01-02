// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "../core/credentials/basic_credentials.dart";
import "../core/credentials/callbacks.dart";
import "../core/protocol_interfaces/protocol_client.dart";
import "../core/protocol_interfaces/protocol_client_factory.dart";
import "constants.dart";
import "mqtt_client.dart";
import "mqtt_config.dart";

/// [ProtocolClientFactory] for creating [MqttClient]s.
final class MqttClientFactory implements ProtocolClientFactory {
  /// Instatiates a new [MqttClientFactory].
  MqttClientFactory({
    MqttConfig? mqttConfig,
    AsyncClientSecurityCallback<BasicCredentials>? basicCredentialsCallback,
  })  : _mqttConfig = mqttConfig,
        _basicCredentialsCallback = basicCredentialsCallback;

  final MqttConfig? _mqttConfig;

  final AsyncClientSecurityCallback<BasicCredentials>?
      _basicCredentialsCallback;

  @override
  ProtocolClient createClient() => MqttClient(
        mqttConfig: _mqttConfig,
        basicCredentialsCallback: _basicCredentialsCallback,
      );

  @override
  bool destroy() {
    return true;
  }

  @override
  bool init() {
    return true;
  }

  @override
  Set<String> get schemes => {mqttUriScheme, mqttSecureUriScheme};
}
