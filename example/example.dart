// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

// ignore_for_file: avoid_print

import 'package:dart_wot/dart_wot.dart';

final Map<String, BasicCredentials> basicCredentials = {
  'urn:test': BasicCredentials('rw', 'readwrite')
};

Future<BasicCredentials?> basicCredentialsCallback(
  Uri uri,
  Form? form, [
  BasicCredentials? invalidCredentials,
]) async {
  final id = form?.thingDescription.identifier;

  return basicCredentials[id];
}

Future<void> main(List<String> args) async {
  final CoapClientFactory coapClientFactory = CoapClientFactory();
  final HttpClientFactory httpClientFactory = HttpClientFactory();
  final MqttClientFactory mqttClientFactory = MqttClientFactory();
  final servient = Servient(
    clientSecurityProvider: ClientSecurityProvider(
      basicCredentialsCallback: basicCredentialsCallback,
    ),
  )
    ..addClientFactory(coapClientFactory)
    ..addClientFactory(httpClientFactory)
    ..addClientFactory(mqttClientFactory);
  final wot = await servient.start();

  const thingDescriptionJson = '''
  {
    "@context": "http://www.w3.org/ns/td",
    "title": "Test Thing",
    "id": "urn:test",
    "base": "coap://coap.me",
    "security": ["auto_sc"],
    "securityDefinitions": {
      "auto_sc": {
        "scheme": "auto"
      }
    },
    "properties": {
      "status": {
        "forms": [
          {
            "href": "/hello"
          }
        ]
      },
      "status2": {
        "observable": true,
        "forms": [
          {
            "href": "mqtt://test.mosquitto.org:1884",
            "mqv:filter": "test",
            "op": ["readproperty", "observeproperty"],
            "contentType": "text/plain"
          }
        ]
      }
    },
    "actions": {
      "toggle": {
        "forms": [
          {
            "href": "mqtt://test.mosquitto.org:1884",
            "mqv:topic": "test",
            "mqv:retain": true
          }
        ]
      }
    }
  }
  ''';

  final thingDescription = ThingDescription(thingDescriptionJson);
  final consumedThing = await wot.consume(thingDescription);
  final status = await consumedThing.readProperty('status');
  final value = await status.value();
  print(value);
  final subscription = await consumedThing.observeProperty(
    'status2',
    (data) async {
      final value = await data.value();
      print(value);
    },
  );

  await consumedThing.invokeAction('toggle', 'Hello World!');
  await consumedThing.invokeAction('toggle', 'Hello World!');
  await consumedThing.invokeAction('toggle', 'Hello World!');
  await consumedThing.invokeAction('toggle', 'Hello World!');
  await subscription.stop();

  final thingUri = Uri.parse(
    'https://raw.githubusercontent.com/w3c/wot-testing'
    '/b07fa6124bca7796e6ca752a3640fac264d3bcbc/events/2021.03.Online/TDs'
    '/Oracle/oracle-Festo_Shared.td.jsonld',
  );

  final thingDiscovery = wot.discover(ThingFilter(url: thingUri));

  await for (final thingDescription in thingDiscovery) {
    final consumedDiscoveredThing = await wot.consume(thingDescription);
    print(
      'The title of the fetched TD is '
      '${consumedDiscoveredThing.thingDescription.title}.',
    );
  }

  await consumedThing.invokeAction('toggle', 'Bye World!');
  await consumedThing.readAndPrintProperty('status2');
  print('Done!');
}

extension ReadAndPrintExtension on ConsumedThing {
  Future<void> readAndPrintProperty(String propertyName) async {
    final output = await readProperty(propertyName);
    final value = await output.value();
    print(value);
  }
}
