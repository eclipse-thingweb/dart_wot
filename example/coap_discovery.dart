// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/dart_wot.dart';

const propertyName = "string";

Future<void> main(List<String> args) async {
  final servient = Servient()..addClientFactory(CoapClientFactory());

  final wot = await servient.start();

  await for (final thingDescription in wot.discover(ThingFilter(
      url: Uri.parse("coap://plugfest.thingweb.io:5683/testthing"),
      method: DiscoveryMethod.direct))) {
    final consumedThing = await wot.consume(thingDescription);

    try {
      await consumedThing.writeProperty(propertyName, "Hello World!");
      var value = await consumedThing.readProperty(propertyName);
      print(value);
      await consumedThing.writeProperty(propertyName, "Bye World!");
      value = await consumedThing.readProperty(propertyName);
      print(value);
    } on Exception catch (e) {
      print(e);
    }
  }
}
