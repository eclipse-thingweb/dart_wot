// Copyright 2023 The NAMIB Project Developers. All rights reserved.
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

void handleThingDescription(ThingDescription thingDescription) =>
    print('Discovered TD with title "${thingDescription.title}".');

Future<void> main(List<String> args) async {
  final servient = Servient()..addClientFactory(CoapClientFactory());

  final wot = await servient.start();
  final uri = Uri.parse('_wot._udp.local');

  // Example using for-await-loop
  try {
    await for (final thingDescription
        in wot.discover(uri, method: DiscoveryMethod.dnsServiceDiscovery)) {
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
  wot.discover(uri, method: DiscoveryMethod.dnsServiceDiscovery).listen(
        handleThingDescription,
        onError: (error) => print('Encountered an error: $error'),
        onDone: () => print('Discovery with "listen" has finished.'),
      );
}
