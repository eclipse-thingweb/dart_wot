// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

// ignore_for_file: avoid_print

import "dart:convert";

import "package:dart_wot/binding_coap.dart";
import "package:dart_wot/binding_http.dart";
import "package:dart_wot/core.dart";

Future<void> main(List<String> args) async {
  final servient = Servient.create(
    clientFactories: [
      CoapClientFactory(),
    ],
  );
  final wot = await servient.start();

  final url =
      Uri.parse("coap://test-jan.testbed.maveric.internal/.well-known/wot");
  print("Requesting TD from $url ...");
  final thingDescription = await wot.requestThingDescription(url);

  print(thingDescription.toJson());

  final consumedThing = await wot.consume(thingDescription);

  final uriVariables = {
    "topic": "text2lines/dataMain",
  };

  // await consumedThing.invokeAction(
  //   "subscribeToTopic",
  //   uriVariables: uriVariables,
  // );

  // final blargh = await consumedThing.observeProperty(
  //   "pullInterface",
  //   (interactionOutput) {
  //     interactionOutput.data?.transform(utf8.decoder).forEach(print);
  //   },
  //   uriVariables: uriVariables,
  // );

  final yeah = [
    "repairs. It is safer to ask the student to leave the classroom than it is to take",
    "the phone away completely.Cell phone restrictions in classrooms should also include specific disciplinary",
    "actions for breaking the rules. If a student is caught using the phone in",
    "class, he or she should be excused for the rest of the day. Professors should",
    "refrain from physically taking possession of a student’s phone because of",
  ];

  for (final yo in yeah) {
    await consumedThing.writeProperty(
      "pushInterface",
      InteractionInput.fromString(yo),
      uriVariables: {
        "topic": "/text2lines/dataMain",
      },
    );
  }

  // print(
  //   "Successfully retrieved and consumed TD with title "
  //   '"${thingDescription.title}"!',
  // );

  // print(consumedThing.thingDescription.events);
  // final subscription = await consumedThing.subscribeEvent("change", print);

  // print("Incrementing counter ...");
  // await consumedThing.invokeAction("increment");

  // final status = await consumedThing.readProperty("count");
  // final value = await status.value();
  // print("New counter value: $value");

  // await subscription.stop();
}
