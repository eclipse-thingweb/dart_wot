// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:convert";
import "dart:io";

import "package:args/args.dart";
import "package:dart_wot/binding_coap.dart";
import "package:dart_wot/binding_http.dart";
import "package:dart_wot/binding_mqtt.dart";
import "package:dart_wot/core.dart";

const success = 0;

Future<void> main(List<String> args) async {
  exitCode = success;

  final servient = Servient.create(
    clientFactories: [
      CoapClientFactory(),
      HttpClientFactory(),
      MqttClientFactory(),
    ],
  );

  final wot = await servient.start();

  final argParser = ArgParser()
    ..addCommand("read-property")
    ..addCommand("request-td");

  final argResults = argParser.parse(args);

  final command = argResults.command;

  switch (command?.name) {
    case "read-property":
      final uri = Uri.parse(command?.arguments.first ?? "");
      final thingDescription = await wot.requestThingDescription(uri);

      final consumedThing = await wot.consume(thingDescription);
      final propertyKey = command?.arguments.elementAtOrNull(1) ?? "";

      final interactionOutput = await consumedThing.readProperty(propertyKey);
      final value = await interactionOutput.value();

      stdout.write(value);
    case "request-td":
      final uri = Uri.parse(command?.arguments.first ?? "");
      final thingDescription = await wot.requestThingDescription(uri);
      writeThingDescription(thingDescription);
  }
}

void writeThingDescription(ThingDescription thingDescription) {
  // TODO: Also support other serialization formats (especially CBOR)
  final thingDescriptionJson = jsonEncode(thingDescription.toJson());
  stdout.write(thingDescriptionJson);
}
