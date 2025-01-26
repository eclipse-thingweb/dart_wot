// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

/// Protocol binding for the Message Queue Telemetry Transport (MQTT). Follows
/// the latest [WoT Binding Templates Specification][spec link] for MQTT.
///
/// [spec link]: https://w3c.github.io/wot-binding-templates/bindings/protocols/mqtt
library;

export "src/binding_mqtt/mqtt_client_factory.dart";
export "src/binding_mqtt/mqtt_config.dart";
