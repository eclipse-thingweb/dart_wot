// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

// ignore_for_file: avoid_print

import 'package:dart_wot/dart_wot.dart';

Future<void> main(List<String> args) async {
  final servient = Servient(
    clientFactories: [
      CoapClientFactory(),
    ],
  );
  final wot = await servient.start();

  final url = Uri.parse('coap://plugfest.thingweb.io/counter');
  print('Requesting TD from $url ...');
  final thingDescription = await wot.requestThingDescription(url);

  final consumedThing = await wot.consume(thingDescription);
  print(
    'Successfully retrieved and consumed TD with title '
    '"${thingDescription.title}"!',
  );

  print('Incrementing counter ...');
  await consumedThing.invokeAction('increment');

  final status = await consumedThing.readProperty('count');
  final value = await status.value();
  print('New counter value: $value');
}
