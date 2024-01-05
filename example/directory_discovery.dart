// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

// ignore_for_file: avoid_print

import "package:dart_wot/binding_http.dart";
import "package:dart_wot/core.dart";

Future<void> main(List<String> args) async {
  final servient = Servient(
    clientFactories: [
      HttpClientFactory(),
    ],
  );

  final wot = await servient.start();
  // FIXME(JRKhb): The "things" property currently points to "localhost",
  //               preventing this example from working
  final url = Uri.parse("https://zion.vaimee.com/.well-known/wot");

  final thingDiscovery = await wot.exploreDirectory(url);

  await for (final thingDescription in thingDiscovery) {
    print(thingDescription);
  }
}
