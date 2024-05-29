// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:meta/meta.dart";
import "package:mqtt_client/mqtt_client.dart";

import "constants.dart";

/// Allows for configuring the behavior of MQTT clients and servers.
///
/// The default [QoS] values for the different operation types will be used if
/// no Quality of Service is defined in the respective form.
///
/// If no [readTimeout] is defined, a [defaultReadTimeout] of
/// 10 seconds will be used.
/// Furthermore, the [keepAlivePeriod] defaults to a [defaultKeepAlivePeriod] of
/// 20 seconds.
class MqttConfig {
  /// Creates a new [MqttConfig] object.
  MqttConfig({
    this.defaultReadQoS = QoS.atMostOnce,
    this.defaultWriteQoS = QoS.atMostOnce,
    this.defaultActionQoS = QoS.atMostOnce,
    this.defaultSubscribeQoS = QoS.atLeastOnce,
    this.readTimeout = defaultReadTimeout,
    this.keepAlivePeriod = defaultKeepAlivePeriod,
  });

  /// Default Quality of Service for `readproperty` operations.
  final QoS defaultReadQoS;

  /// Default Quality of Service for `writeproperty` operations.
  final QoS defaultWriteQoS;

  /// Default Quality of Service for `invokeaction` operations.
  final QoS defaultActionQoS;

  /// Default Quality of Service for `observeproperty` and `subscribeevent`
  /// operations.
  final QoS defaultSubscribeQoS;

  /// Duration MQTT connections are kept alive in seconds.
  final int keepAlivePeriod;

  /// Timeout value used for `readproperty` operations.
  ///
  /// If no value has been read until the timeout has expired, the operation
  /// will be canceled.
  final Duration readTimeout;
}

/// Enum for indicating the default Quality of Service (QoS) that should be used
/// for triggering interaction affordances.
enum QoS {
  /// Quality of Service level "at most once" (numeric value: 0).
  atMostOnce(MqttQos.atMostOnce),

  /// Quality of Service value "at least once" (numeric value: 1).
  atLeastOnce(MqttQos.atLeastOnce),

  /// Quality of Service value "exactly once" (numeric value: 2).
  exactlyOnce(MqttQos.exactlyOnce);

  /// Constructor
  const QoS(this.mqttQoS);

  /// Implementation-specific QoS value for MQTT versions 3.1 and 3.1.1
  @internal
  final MqttQos mqttQoS;
}
