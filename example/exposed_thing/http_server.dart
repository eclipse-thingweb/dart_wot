// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

// ignore_for_file: avoid_print

import "package:dart_wot/binding_http.dart";
import "package:dart_wot/core.dart";

String property = "hi :)";

void main() async {
  final servient = Servient.create(
    clientFactories: [HttpClientFactory()],
    servers: [HttpServer(HttpConfig(port: 3000))],
  );

  final wot = await servient.start();

  final exposedThing = await wot.produce({
    "@context": "https://www.w3.org/2022/wot/td/v1.1",
    "title": "My Lamp Thing",
    "id": "test",
    "properties": {
      "status": {
        "type": "string",
        "forms": [
          {
            "href": "/status",
          }
        ],
      },
    },
    "actions": {
      "toggle": {
        "input": {
          "type": "boolean",
        },
        "output": {
          "type": "null",
        },
        "forms": [
          {
            "href": "/toggle",
          }
        ],
      },
    },
  });

  exposedThing
    ..setPropertyReadHandler("status", ({
      data,
      formIndex,
      uriVariables,
    }) async {
      return InteractionInput.fromString(property);
    })
    ..setPropertyWriteHandler("status", (
      interactionOutput, {
      data,
      formIndex,
      uriVariables,
    }) async {
      final value = await interactionOutput.value();

      if (value is String) {
        property = value;
        return;
      }

      throw const FormatException();
    })
    ..setActionHandler("toggle", (
      actionInput, {
      data,
      formIndex,
      uriVariables,
    }) async {
      print(await actionInput.value());

      return InteractionInput.fromNull();
    });

  final thingDescription = await wot
      .requestThingDescription(Uri.parse("http://localhost:3000/test"));
  print(thingDescription.toJson());
  final consumedThing = await wot.consume(thingDescription);

  var value = await (await consumedThing.readProperty("status")).value();
  print(value);

  await consumedThing.writeProperty(
    "status",
    DataSchemaValueInput(DataSchemaValue.fromString("bye")),
  );

  value = await (await consumedThing.readProperty("status")).value();
  print(value);

  final actionOutput = await consumedThing.invokeAction(
    "toggle",
    input: InteractionInput.fromBoolean(true),
  );

  print(await actionOutput.value());

  await servient.shutdown();
}
