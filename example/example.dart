// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/dart_wot.dart';

Future<void> main(List<String> args) async {
  final CoapClientFactory coapClientFactory = CoapClientFactory();
  final servient = Servient()..addClientFactory(coapClientFactory);
  final wot = await servient.start();

  final thingDescriptionJson = '''
  {
    "@context": "http://www.w3.org/ns/td",
    "title": "Test Thing",
    "base": "coap://coap.me",
    "security": ["nosec_sc"],
    "securityDefinitions": {
      "nosec_sc": {
        "scheme": "nosec"
      }
    },
    "properties": {
      "status": {
        "forms": [
          {
            "href": "/hello"
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
