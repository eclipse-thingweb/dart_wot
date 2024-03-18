// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

// ignore_for_file: avoid_print

import "package:dart_wot/binding_ndn.dart";
import "package:dart_wot/core.dart";
import "package:dart_wot/src/binding_ndn/ndn_config.dart";

Future<void> main() async {
  final faceUri = Uri.parse("tcp4://localhost:6363");
  final ndnConfig = NdnConfig(
    faceUri: faceUri,
  );

  final servient = Servient(
    clientFactories: [NdnClientFactory(ndnConfig: ndnConfig)],
  );

  final wot = await servient.start();

  final thingDescription = {
    "@context": "https://www.w3.org/2022/wot/td/v1.1",
    "title": "NDN Thing",
    "id": "urn:test",
    "securityDefinitions": {
      "nosec_sc": {"scheme": "nosec"},
    },
    "security": "nosec_sc",
    "properties": {
      "ping": {
        "forms": [
          {
            "contentType": "text/plain",
            "href": "ndn:///ndn/ping/9001",
          },
        ],
      },
    },
  }.toThingDescription();

  final consumedThing = await wot.consume(thingDescription);

  final result = await consumedThing.readProperty("ping");

  print(await result.value());

  await servient.shutdown();
}
