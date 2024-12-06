// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

// ignore_for_file: avoid_print

import "package:dart_wot/binding_http.dart";
import "package:dart_wot/core.dart";

Future<void> main() async {
  final servient = Servient.create(
    clientFactories: [
      HttpClientFactory(),
    ],
  );
  final wot = await servient.start();

  final url = Uri.parse("http://plugfest.thingweb.io:8081");
  print("Requesting TD from $url ...");
  final thingDiscoveryProcess = await wot.exploreDirectory(url);

  thingDiscoveryProcess.listen(
    (thingDescription) => print(thingDescription.title),
    onError: print,
  );

  await servient.shutdown();
}
