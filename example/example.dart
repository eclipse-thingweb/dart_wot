// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/dart_wot.dart';

Future<void> main(List<String> args) async {
  final CoapClientFactory coapClientFactory = CoapClientFactory();
  final HttpClientFactory httpClientFactory = HttpClientFactory();
  final servient = Servient()
    ..addClientFactory(coapClientFactory)
    ..addClientFactory(httpClientFactory);
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

  final thingUri = Uri.parse("https://raw.githubusercontent.com/w3c/wot-testing"
      "/b07fa6124bca7796e6ca752a3640fac264d3bcbc/events/2021.03.Online/TDs"
      "/Oracle/oracle-Festo_Shared.td.jsonld");

  final thingDiscovery =
      wot.discover(ThingFilter(url: thingUri, method: DiscoveryMethod.direct));

  await for (final thingDescription in thingDiscovery) {
    final consumedDiscoveredThing = await wot.consume(thingDescription);
    print("The title of the fetched TD is "
        "${consumedDiscoveredThing.thingDescription.title}.");
  }

  print("Done!");
}
