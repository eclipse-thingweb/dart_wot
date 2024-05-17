// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

// ignore_for_file: avoid_print

import "package:dart_wot/binding_coap.dart";
import "package:dart_wot/core.dart";

Future<void> main(List<String> args) async {
  final servient = Servient(
    clientFactories: [CoapClientFactory()],
    discoveryConfiguration: [
      CoreLinkFormatConfiguration(
        Uri.parse("coap://plugfest.thingweb.io"),
      ),
    ],
  );

  final wot = await servient.start();

  await for (final thingDescription in wot.discover()) {
    print(thingDescription.title);

    if (thingDescription.title != "Smart-Coffee-Machine") {
      continue;
    }

    final consumedThing = await wot.consume(thingDescription);

    try {
      final statusBefore =
          await consumedThing.readProperty("allAvailableResources");
      print(await statusBefore.value());

      final result = await consumedThing.invokeAction("makeDrink");

      print(await result.value());

      final statusAfter =
          await consumedThing.readProperty("allAvailableResources");
      print(await statusAfter.value());
    } on Exception catch (e) {
      print(e);
    }
  }
}
