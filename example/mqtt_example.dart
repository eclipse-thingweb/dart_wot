// Copyright 2023 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

// ignore_for_file: avoid_print

import 'package:dart_wot/dart_wot.dart';

const thingDescriptionJson = '''
  {
    "@context": "https://www.w3.org/2022/wot/td/v1.1",
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
        "input": {
          "type": "string"
        },
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

final Map<String, BasicCredentials> basicCredentials = {
  'urn:test': BasicCredentials('rw', 'readwrite'),
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
  final servient = Servient(
    clientFactories: [
      MqttClientFactory(basicCredentialsCallback: basicCredentialsCallback),
    ],
  );

  final wot = await servient.start();

  final thingDescription = ThingDescription(thingDescriptionJson);
  final consumedThing = await wot.consume(thingDescription);
  await consumedThing.readAndPrintProperty('status');

  final subscription = await consumedThing.observeProperty(
    'status',
    (data) async {
      final value = await data.value();
      print(value);
    },
  );

  final actionInput = 'Hello World'.asInteractionInput();

  await consumedThing.invokeAction('toggle', input: actionInput);
  await consumedThing.invokeAction('toggle', input: actionInput);
  await consumedThing.invokeAction('toggle', input: actionInput);
  await consumedThing.invokeAction('toggle', input: actionInput);
  await subscription.stop();

  await consumedThing.invokeAction('toggle', input: actionInput);
  await consumedThing.readAndPrintProperty('status');
  print('Done!');
}

extension ReadAndPrintExtension on ConsumedThing {
  Future<void> readAndPrintProperty(String propertyName) async {
    final output = await readProperty(propertyName);
    final value = await output.value();
    print(value);
  }
}
