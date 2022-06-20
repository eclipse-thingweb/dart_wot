// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

// ignore_for_file: avoid_print

import 'package:dart_wot/dart_wot.dart';

const propertyName = 'string';

extension PrintExtension on InteractionOutput {
  Future<void> printValue() async {
    print(await value());
  }
}

Future<void> handleThingDescription(
  WoT wot,
  ThingDescription thingDescription,
) async {
  final consumedThing = await wot.consume(thingDescription);
  await consumedThing.writeProperty(propertyName, 'Hello World!');
  var output = await consumedThing.readProperty(propertyName);
  await output.printValue();
  await consumedThing.writeProperty(propertyName, 'Bye World!');
  output = await consumedThing.readProperty(propertyName);
  await output.printValue();
}

Future<void> main(List<String> args) async {
  final servient = Servient()..addClientFactory(CoapClientFactory());

  final wot = await servient.start();
  final thingFilter = ThingFilter(
    url: Uri.parse('coap://plugfest.thingweb.io:5683/testthing'),
  );

  // Example using for-await-loop
  try {
    await for (final thingDescription in wot.discover(thingFilter)) {
      await handleThingDescription(wot, thingDescription);
    }
    print('Discovery with "await for" has finished.');
  } on Exception catch (error) {
    print(error);
  }

  // Example using the .listen() method, allowing for error handling
  //
  // Notice how the "onDone" callback is called before the result is passed
  // to the handleThingDescription function.
  wot.discover(thingFilter).listen(
    (thingDescription) async {
      await handleThingDescription(wot, thingDescription);
    },
    onError: (error) => print('Encountered an error: $error'),
    onDone: () => print('Discovery with "listen" has finished.'),
  );
}
