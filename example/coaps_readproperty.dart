// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

// ignore_for_file: avoid_print

import "dart:typed_data";

import "package:dart_wot/binding_coap.dart";
import "package:dart_wot/core.dart";

/// Matches [PskCredentials] by hostname and URI scheme.
final Map<Uri, PskCredentials> _pskCredentialsStore = {
  Uri(host: "californium.eclipseprojects.io", scheme: "coaps"): PskCredentials(
    identity: Uint8List.fromList("Client_identity".codeUnits),
    preSharedKey: Uint8List.fromList("secretPSK".codeUnits),
  ),
};

PskCredentials? _pskCredentialsCallback(
  Uri uri,
  Form? form,
  String? identityHint,
) {
  final key = Uri(scheme: uri.scheme, host: uri.host);

  return _pskCredentialsStore[key];
}

Future<void> main(List<String> args) async {
  final CoapClientFactory coapClientFactory = CoapClientFactory(
    coapConfig: const CoapConfig(
      dtlsCiphers: "PSK-AES128-CCM8",
    ),
    pskCredentialsCallback: _pskCredentialsCallback,
  );

  final servient = Servient.create(
    clientFactories: [
      coapClientFactory,
    ],
  );

  final wot = await servient.start();

  const thingDescriptionJson = {
    "@context": "https://www.w3.org/2022/wot/td/v1.1",
    "title": "Test Thing",
    "base": "coaps://californium.eclipseprojects.io",
    "security": ["psk_sc"],
    "securityDefinitions": {
      "psk_sc": {"scheme": "psk", "identity": "Client_identity"},
    },
    "properties": {
      "status": {
        "forms": [
          {"href": "/test"},
        ],
      },
    },
  };

  final thingDescription = thingDescriptionJson.toThingDescription();
  final consumedThing = await wot.consume(thingDescription);
  final status = await consumedThing.readProperty("status");
  final value = await status.value();
  print(value);
}
