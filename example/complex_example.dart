// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/dart_wot.dart';

final thingDescriptionJson = '''
{
  "@context": ["http://www.w3.org/ns/td", {"@language": "de"}],
  "title": "Test Thing",
  "id": "urn:test",
  "base": "coap://coap.me",
  "securityDefinitions": {
    "nosec_sc": {
      "scheme": "nosec",
      "descriptions": {
        "de": "Keine Sicherheit",
        "en": "No Security"
      }
    },
    "basic_sc": {
      "scheme": "basic",
      "description": "Test"
    }
  },
  "security": "nosec_sc",
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
    },
    "anotherStatus": {
            "uriVariables": {
              "test": {
                "type": "string"
              }
            },
      "forms": [
        {
          "href": "coap://coap.me/query{?test}"
        }
      ]
    },
    "test": {
      "forms": [
        {
          "href": "http://example.org",
          "security": ["basic_sc"]
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
  final coapConfig = CoapConfig(blocksize: 64);
  final CoapClientFactory coapClientFactory = CoapClientFactory(coapConfig);
  final HttpClientFactory httpClientFactory = HttpClientFactory();
  final servient = Servient()
    ..addClientFactory(coapClientFactory)
    ..addClientFactory(httpClientFactory)
    ..addCredentials(
        "urn:test", "basic_sc", BasicCredentials("username", "password"));
  final wot = await servient.start();

  final thingDescription = ThingDescription(thingDescriptionJson);
  final consumedThing = await wot.consume(thingDescription);
  final status = await consumedThing.readProperty("status");
  final value1 = await status.value();
  print(value1);
  await consumedThing.invokeAction("toggle");
  final status2 = await consumedThing.readProperty("differentStatus");
  final value2 = await status2.value();
  print(value2);

  final status3 = await consumedThing.readProperty(
      "anotherStatus", InteractionOptions(uriVariables: {"test": "hi"}));
  final value3 = await status3.value();
  print(value3);

  Subscription? subscription;

  // TODO(JKRhb): Turn into a "real" observation example.
  subscription = await consumedThing.observeProperty("status", (data) async {
    final value = await data.value();
    print(value);
    await subscription?.stop();
  });

  await consumedThing.readProperty("test");

  final thingDiscovery = wot.discover(ThingFilter(
      "https://raw.githubusercontent.com/w3c/wot-testing"
      "/b07fa6124bca7796e6ca752a3640fac264d3bcbc/events/2021.03.Online/TDs"
      "/Oracle/oracle-Festo_Shared.td.jsonld",
      DiscoveryMethod.direct));

  final discoveredThingDescription = await thingDiscovery.next();
  thingDiscovery.stop();
  final consumedDiscoveredThing = await wot.consume(discoveredThingDescription);

  print("The title of the fetched TD is "
      "${consumedDiscoveredThing.thingDescription.title}.");
  print("Done!");
}
