// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

// ignore_for_file: avoid_print

import "package:dart_wot/binding_http.dart";
import "package:dart_wot/core.dart";

const username = "username";
const password = "password";
const thingDescriptionJson = {
  "@context": "https://www.w3.org/2022/wot/td/v1.1",
  "title": "Test Thing",
  "id": "urn:test",
  "base": "https://httpbin.org",
  "securityDefinitions": {
    "auto_sc": {"scheme": "auto"},
    "basic_sc": {"scheme": "basic"},
  },
  "security": "auto_sc",
  "properties": {
    "status": {
      "forms": [
        {"href": "/basic-auth/$username/$password"},
      ],
    },
    "status2": {
      "forms": [
        {"href": "/basic-auth/$username/$password", "security": "basic_sc"},
      ],
    },
  },
};

const basicCredentials = BasicCredentials("username", "password");

final Map<String, BasicCredentials> basicCredentialsMap = {
  "httpbin.org": basicCredentials,
};

Future<BasicCredentials?> basicCredentialsCallback(
  Uri uri,
  AugmentedForm? form,
  BasicCredentials? invalidCredentials,
) async =>
    basicCredentialsMap[uri.authority];

/// Illustrates the usage of both the basic and the automatic security scheme,
/// with a server supporting basic authentication.
Future<void> main(List<String> args) async {
  final httpClientFactory = HttpClientFactory(
    basicCredentialsCallback: basicCredentialsCallback,
  );
  final servient = Servient.create(
    clientFactories: [
      httpClientFactory,
    ],
  );
  final wot = await servient.start();

  final thingDescription = thingDescriptionJson.toThingDescription();
  final consumedThing = await wot.consume(thingDescription);
  final status = await consumedThing.readProperty("status");

  print(await status.value());

  final status2 = await consumedThing.readProperty("status2");

  print(await status2.value());
}
