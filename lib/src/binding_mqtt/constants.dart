// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

/// The URI scheme for unsecured MQTT (using TCP).
///
/// Note that this scheme is not standardized yet, as there is an ongoing debate
/// about URI schemes in the context of MQTT.
const mqttUriScheme = "mqtt";

/// The default port number used for the [mqttUriScheme].
const defaultMqttPort = 1883;

/// The URI scheme for secure MQTT (using TCP and TLS).
///
/// Note that this scheme is not standardized yet, as there is an ongoing debate
/// about URI schemes in the context of MQTT.
const mqttSecureUriScheme = "mqtts";

/// The default port number used for the [mqttSecureUriScheme].
const defaultMqttSecurePort = 8883;

/// URI pointing to the MQTT vocabulary.
///
/// Used for resolving MQTT-related compact URIs (CURIEs) in TDs. Note that
/// the MQTT vocabulary is not standardized yet, so this URI will change in
/// future versions of this library.
const mqttContextUri = "http://www.example.org/mqtt-binding#";

/// The default prefix used in MQTT-related compact URIs (CURIEs) in TDs.
const defaultMqttPrefix = "mqv";

/// Default timeout length used for reading properties and discovering TDs.
const defaultTimeout = Duration(seconds: 10);

/// Default duration MQTT connections are kept alive in seconds.
const defaultKeepAlivePeriod = 20;

/// Default content type when returning a `Content` object from the MQTT
/// binding.
///
/// Evaluates to `'application/octet-stream'.
const defaultContentType = "application/octet-stream";

/// Content type used for the Content objects returned by discovery using MQTT.
///
/// Evaluates to `application/td+json`.
// TODO: Should probably be redefined globally
const discoveryContentType = "application/td+json";
