// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/dart_wot.dart';

const propertyName = "status";
const actionName = "toggle";

Future<void> main(List<String> args) async {
  final servient = Servient()..addClientFactory(CoapClientFactory());

  final wot = await servient.start();

  // TODO(JKRhb): Replace with an endpoint providing CoRE Format Links pointing
  //              to TDs. At the moment, this URI is just for illustrative
  //              purpose and will not return actual Thing Description links.
  final discoveryUri = Uri.parse("coap://coap.me/.well-known/core");
  final thingFilter =
      ThingFilter(url: discoveryUri, method: DiscoveryMethod.coreLinkFormat);

  await for (final thingDescription in wot.discover(thingFilter)) {
    final consumedThing = await wot.consume(thingDescription);

    try {
      final statusBefore = await consumedThing.readProperty(propertyName);
      print(await statusBefore.value());

      await consumedThing.invokeAction(actionName);

      final statusAfter = await consumedThing.readProperty(propertyName);
      print(await statusAfter.value());
    } on Exception catch (e) {
      print(e);
    }
  }
}
