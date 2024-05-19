// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

// ignore_for_file: avoid_print

import "package:dart_wot/binding_coap.dart";
import "package:dart_wot/binding_http.dart";
import "package:dart_wot/core.dart";

const thingDescriptionJson = {
  "@context": [
    "https://www.w3.org/2022/wot/td/v1.1",
    {"@language": "de", "coap": "http://www.example.org/coap-binding#"},
  ],
  "title": "Test Thing",
  "id": "urn:test",
  "base": "coap://coap.me",
  "securityDefinitions": {
    "nosec_sc": {
      "scheme": "nosec",
      "descriptions": {"de": "Keine Sicherheit", "en": "No Security"},
    },
    "basic_sc": {"scheme": "basic", "description": "Test"},
  },
  "security": "nosec_sc",
  "properties": {
    "status": {
      "observable": true,
      "forms": [
        {"href": "/.well-known/core"},
        {
          "href": "coap://californium.eclipseprojects.io/obs",
          "op": ["observeproperty", "unobserveproperty"],
          "subprotocol": "cov:observe",
        }
      ],
    },
    "differentStatus": {
      "forms": [
        {"href": "coap://coap.me", "coap:method": "GET"},
      ],
    },
    "anotherStatus": {
      "uriVariables": {
        "test": {"type": "string"},
      },
      "forms": [
        {"href": "coap://coap.me/query{?test}"},
      ],
    },
    "test": {
      "forms": [
        {
          "href": "http://example.org",
          "security": ["basic_sc"],
        }
      ],
    },
  },
  "actions": {
    "toggle": {
      "forms": [
        {"href": "coap://coap.me/large-create"},
      ],
    },
  },
  "events": {
    "overheating": {
      "forms": [
        {"href": "coap://coap.me"},
      ],
    },
  },
};

final Map<String, BasicCredentials> basicCredentials = {
  "urn:test": const BasicCredentials("username", "password"),
};

Future<BasicCredentials?> basicCredentialsCallback(
  Uri uri,
  AugmentedForm? form, [
  BasicCredentials? invalidCredentials,
]) async {
  final id = form?.tdIdentifier;

  return basicCredentials[id];
}

Future<void> main() async {
  final coapClientFactory = CoapClientFactory(
    coapConfig: const CoapConfig(blocksize: 64),
  );

  final httpClientFactory =
      HttpClientFactory(basicCredentialsCallback: basicCredentialsCallback);

  final servient = Servient(
    clientFactories: [
      coapClientFactory,
      httpClientFactory,
    ],
  );
  final wot = await servient.start();

  final thingDescription = thingDescriptionJson.toThingDescription();
  final consumedThing = await wot.consume(thingDescription);
  final status = await consumedThing.readProperty("status");
  final value1 = await status.value();
  print(value1);
  await consumedThing.invokeAction("toggle");
  final status2 = await consumedThing.readProperty("differentStatus");
  final value2 = await status2.value();
  print(value2);

  final status3 = await consumedThing.readProperty(
    "anotherStatus",
    uriVariables: {"test": "hi"},
  );
  final value3 = await status3.value();
  print(value3);

  Subscription? subscription;

  int observationCounter = 0;
  subscription = await consumedThing.observeProperty("status", (data) async {
    if (observationCounter++ == 3) {
      print("Done! Cancelling subscription.");
      await subscription?.stop();
    }

    if (subscription?.active ?? false) {
      final value = await data.value();
      print("Received observation data: $value");
    }
  });

  await consumedThing.readProperty("test");

  final thingUri = Uri.parse(
    "https://raw.githubusercontent.com/w3c/wot-testing"
    "/b07fa6124bca7796e6ca752a3640fac264d3bcbc/events/2021.03.Online/TDs"
    "/Oracle/oracle-Festo_Shared.td.jsonld",
  );

  final discoveredThingDescription =
      await wot.requestThingDescription(thingUri);

  final consumedDiscoveredThing = await wot.consume(discoveredThingDescription);
  print(
    "The title of the fetched TD is "
    "${consumedDiscoveredThing.thingDescription.title}.",
  );
}
