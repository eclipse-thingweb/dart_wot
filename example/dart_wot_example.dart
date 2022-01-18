// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import 'dart:io';

import 'package:dart_wot/dart_wot.dart';

final thingDescriptionJson = '''
{
  "@context": ["http://www.w3.org/ns/td", {"@language": "de"}],
  "title": "Test Thing",
  "base": "coap://coap.me",
  "securityDefinitions": {
    "nosec_sc": {
      "scheme": "nosec",
      "descriptions": {
        "de": "Keine Sicherheit",
        "en": "No Security"
      }
    }
  },
  "properties": {
    "status": {
      "observable": true,
      "forms": [
        {
          "href": "/.well-known/core"
        },
        {
          "href": "/hello",
          "op": ["observeproperty", "unobserveproperty"]
        }
      ]
    },
    "differentStatus": {
      "forms": [
        {
          "href": "coap://coap.me",
          "cov:methodName": "PUT"
        }
      ]
    }
  },
  "actions": {
    "toggle": {
      "forms": [
        {
          "href": "coap://coap.me"
        }
      ]
    }
  },
  "events": {
    "overheating": {
      "forms": [
        {
          "href": "coap://coap.me"
        }
      ]
    }
  }
}
''';

Future<void> main() async {
  // TODO(JKRhb): Add a proper example
  final coapConfig = CoapConfig(blocksize: 64);
  final CoapClientFactory coapClientFactory = CoapClientFactory(coapConfig);
  final HttpClientFactory httpClientFactory = HttpClientFactory();
  final servient = Servient()
    ..addClientFactory(coapClientFactory)
    ..addClientFactory(httpClientFactory);
  final wot = await servient.start();

  final thingDescription = ThingDescription(thingDescriptionJson);
  final consumedThing = await wot.consume(thingDescription);
  final status = await consumedThing.readProperty("status", null);
  final value1 = await status.value();
  print(value1);
  await consumedThing.invokeAction("toggle", null, null);
  final status2 = await consumedThing.readProperty("status", null);
  final value2 = await status2.value();
  print(value2);

  Subscription? subscription;

  // TODO(JKRhb): Turn into a "real" observation example.
  subscription = await consumedThing.observeProperty("status", (data) async {
    final value = await data.value();
    print(value);
    await subscription?.stop();
  });

  final fetchedThingDescription = await fetchThingDescription(
      "https://raw.githubusercontent.com/w3c/wot-testing/b07fa6124bca7796e6ca752a3640fac264d3bcbc/events/2021.03.Online/TDs/Oracle/oracle-Festo_Shared.td.jsonld",
      servient);
  print(fetchedThingDescription.title);

  print("done!");

  // FIXME: For some reason the main function does not terminate without
  //        an exit call
  exit(0);
}
