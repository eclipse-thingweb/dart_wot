// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dart_wot/dart_wot.dart";
import "package:mockito/annotations.dart";
import "package:test/test.dart";
import "http_test.mocks.dart";

@GenerateMocks([ExposedThing])
void main() {
  group("HTTP tests", () {
    setUp(() {
      // Additional setup goes here.
    });

    test("Server tests", () {
      final defaultServer = HttpServer(null);

      expect(defaultServer.port, 80);
      expect(defaultServer.scheme, "http");

      expect(
        () async => defaultServer.start(),
        throwsA(const TypeMatcher<UnimplementedError>()),
      );
      expect(
        () async => defaultServer.stop(),
        throwsA(const TypeMatcher<UnimplementedError>()),
      );
      expect(
        () async => defaultServer.expose(MockExposedThing()),
        throwsA(const TypeMatcher<UnimplementedError>()),
      );

      final customServer1 = HttpServer(HttpConfig(secure: true));

      expect(customServer1.port, 443);
      expect(customServer1.scheme, "https");

      final customServer2 = HttpServer(HttpConfig(port: 9001, secure: true));

      expect(customServer2.port, 9001);
      expect(customServer2.scheme, "https");
    });

    test(
      "HTTP Security Schemes",
      () async {
        const username = "username";
        const password = "password";
        const token = "thisIsTheMostAwesomeTokenEver!";

        // TODO(JKRhb): Does not have an effect in the TD yet (and is negotiated
        //              automatically by http_auth instead)
        const qop = "auth-int";

        const thingDescriptionJson = {
          "@context": ["http://www.w3.org/ns/td"],
          "title": "Test Thing",
          "base": "https://httpbin.org",
          "securityDefinitions": {
            "basic_sc": {"scheme": "basic"},
            "digest_sc": {"scheme": "digest"},
            "bearer_sc": {"scheme": "bearer"},
          },
          "security": "basic_sc",
          "properties": {
            "status": {
              "forms": [
                {"href": "/basic-auth/$username/$password"},
              ],
            },
            "status2": {
              "forms": [
                {
                  "href": "/digest-auth/$qop/$username/$password",
                  "security": "digest_sc",
                  "qop": qop,
                }
              ],
            },
            "status3": {
              "forms": [
                {"href": "/bearer", "security": "bearer_sc"},
              ],
            },
          },
        };

        final parsedTd = ThingDescription.fromJson(thingDescriptionJson);

        final Map<String, BasicCredentials> basicCredentialsStore = {
          "httpbin.org": BasicCredentials(username, password),
        };

        final Map<String, BearerCredentials> bearerCredentialsStore = {
          "httpbin.org": BearerCredentials(token),
        };

        Future<BasicCredentials?> basicCredentialsCallback(
          Uri uri,
          Form? form, [
          BasicCredentials? invalidCredentials,
        ]) async {
          return basicCredentialsStore[uri.host];
        }

        Future<BearerCredentials?> bearerCredentialsCallback(
          Uri uri,
          Form? form, [
          BearerCredentials? invalidCredentials,
        ]) async =>
            bearerCredentialsStore[uri.host];

        final servient = Servient(
          clientFactories: [
            HttpClientFactory(
              basicCredentialsCallback: basicCredentialsCallback,
              bearerCredentialsCallback: bearerCredentialsCallback,
            ),
          ],
        );
        final wot = await servient.start();

        final consumedThing = await wot.consume(parsedTd);
        final result = await consumedThing.readProperty("status");
        final value = await result.value();
        expect(value, {"authenticated": true, "user": username});

        // final result2 = await consumedThing.readProperty('status2');
        // final value2 = await result2.value();
        // expect(value2, {'authenticated': true, 'user': username});

        final result3 = await consumedThing.readProperty("status3");
        final value3 = await result3.value();
        expect(value3, {"authenticated": true, "token": token});
      },
      skip: true,
    );
  });
}
