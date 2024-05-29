// Copyright 2023 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

// ignore_for_file: avoid_print

import "package:dart_wot/binding_coap.dart";
import "package:dart_wot/binding_http.dart";
import "package:dart_wot/core.dart";

void handleThingDescription(ThingDescription thingDescription) =>
    print('Discovered TD with title "${thingDescription.title}".');

Future<void> main(List<String> args) async {
  final servient = Servient.create(
    clientFactories: [
      CoapClientFactory(),
      HttpClientFactory(),
    ],
    discoveryConfigurations: [
      const DnsSdDConfiguration(protocolType: ProtocolType.udp),
    ],
  );

  final wot = await servient.start();

  // Example using for-await-loop
  try {
    await for (final thingDescription in wot.discover()) {
      handleThingDescription(thingDescription);
    }
    print('Discovery with "await for" has finished.');
  } on Exception catch (error) {
    print(error);
  }

  // Example using the .listen() method, allowing for error handling
  //
  // Notice how the "onDone" callback is called before the result is passed
  // to the handleThingDescription function.
  wot.discover().listen(
        handleThingDescription,
        onError: (error) => print("Encountered an error: $error"),
        onDone: () => print('Discovery with "listen" has finished.'),
      );
}
