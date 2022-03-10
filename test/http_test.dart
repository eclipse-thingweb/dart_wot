// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/dart_wot.dart';
import 'package:test/test.dart';

void main() {
  group('HTTP tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('HTTP Security Schemes', () async {
      const username = "username";
      const password = "password";
      const token = "thisIsTheMostAwesomeTokenEver!";

      // TODO(JKRhb): Does not have an effect in the TD yet (and is negotiated
      //              automatically by http_auth instead)
      const qop = "auth-int";

      final thingDescriptionJson = '''
      {
        "@context": ["http://www.w3.org/ns/td"],
        "title": "Test Thing",
        "base": "https://httpbin.org",
        "securityDefinitions": {
          "basic_sc": {
            "scheme": "basic"
          },
          "digest_sc": {
            "scheme": "digest"
          },
          "bearer_sc": {
            "scheme": "bearer"
          }
        },
        "security": "basic_sc",
        "properties": {
          "status": {
            "forms": [
              {
                "href": "/basic-auth/$username/$password"
              }
            ]
          },
          "status2": {
            "forms": [
              {
                "href": "/digest-auth/$qop/$username/$password",
                "security": "digest_sc",
                "qop": "$qop"
              }
            ]
          },
          "status3": {
            "forms": [
              {
                "href": "/bearer",
                "security": "bearer_sc"
              }
            ]
          }
        }
      }
      ''';

      final parsedTd = ThingDescription(thingDescriptionJson);

      final servient = Servient()
        ..addClientFactory(HttpClientFactory())
        ..addCredentials("https://httpbin.org", "basic_sc",
            BasicCredentials(username, password))
        ..addCredentials("https://httpbin.org", "digest_sc",
            DigestCredentials(username, password))
        ..addCredentials(
            "https://httpbin.org", "bearer_sc", BearerCredentials(token));
      final wot = await servient.start();

      final consumedThing = await wot.consume(parsedTd);
      final result = await consumedThing.readProperty("status");
      final value = await result.value();
      expect(value, {"authenticated": true, "user": username});

      final result2 = await consumedThing.readProperty("status2");
      final value2 = await result2.value();
      expect(value2, {"authenticated": true, "user": username});

      final result3 = await consumedThing.readProperty("status3");
      final value3 = await result3.value();
      expect(value3, {"authenticated": true, "token": token});
    });
  });
}
