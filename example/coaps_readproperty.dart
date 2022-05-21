// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/dart_wot.dart';

Future<void> main(List<String> args) async {
  final CoapClientFactory coapClientFactory =
      CoapClientFactory(CoapConfig(useTinyDtls: true));
  final servient = Servient()
    ..addClientFactory(coapClientFactory)
    ..addCredentials(
        "coaps://californium.eclipseprojects.io",
        "psk_sc",
        PskCredentials("secretPSK"
            // ,"Client_identity" // Identity can also be set in Credentials
            ));

  final wot = await servient.start();

  final thingDescriptionJson = '''
  {
    "@context": "http://www.w3.org/ns/td",
    "title": "Test Thing",
    "base": "coaps://californium.eclipseprojects.io",
    "security": ["psk_sc"],
    "securityDefinitions": {
      "psk_sc": {
        "scheme": "psk",
        "identity": "Client_identity"
      }
    },
    "properties": {
      "status": {
        "forms": [
          {
            "href": "/test"
          }
        ]
      }
    }
  }
  ''';

  final thingDescription = ThingDescription(thingDescriptionJson);
  final consumedThing = await wot.consume(thingDescription);
  final status = await consumedThing.readProperty("status");
  final value = await status.value();
  print(value);
}
