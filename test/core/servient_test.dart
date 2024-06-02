// Copyright 2023 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dart_wot/core.dart";
import "package:dart_wot/src/core/definitions/context.dart";
import "package:dart_wot/src/core/implementation/servient.dart";
import "package:test/test.dart";

const testUriScheme = "test";

class MockedProtocolClientFactory implements ProtocolClientFactory {
  @override
  ProtocolClient createClient() {
    throw UnimplementedError("Instantiating a client is not supported yet.");
  }

  @override
  bool destroy() {
    return true;
  }

  @override
  bool init() {
    return true;
  }

  @override
  Set<String> get schemes => {testUriScheme};

  @override
  bool supportsOperation(OperationType operationType, String? subprotocol) =>
      true;
}

void main() {
  group("Servient", () {
    test("should accept a ProtocolClientFactory list as constructor argument",
        () {
      final servient = InternalServient(
        clientFactories: [
          MockedProtocolClientFactory(),
        ],
      );

      expect(servient.clientSchemes, [testUriScheme]);
    });

    test(
      "should allow for adding and removing a ProtocolClientFactory at runtime",
      () {
        final servient = InternalServient()
          ..addClientFactory(MockedProtocolClientFactory());

        expect(servient.clientSchemes.contains(testUriScheme), true);

        servient.removeClientFactory(testUriScheme);

        expect(servient.clientSchemes.contains(testUriScheme), false);
        expect(servient.clientSchemes.length, 0);
      },
    );
  });

  test(
    "should throw a DartWotException when a "
    "ProtocolClientFactory is not registered",
    () {
      final servient = InternalServient();

      expect(
        () => servient.clientFor(testUriScheme),
        throwsA(isA<DartWotException>()),
      );
    },
  );

  test(
    "should throw a FormatException when trying to expand invalid "
    "ExposedThingInits",
    () {
      final servient = InternalServient();

      final exposedThingInit1 = <String, dynamic>{
        "securityDefinitions": 42,
      };

      expect(
        () async => await servient.produce(exposedThingInit1),
        throwsA(isA<FormatException>()),
      );

      final exposedThingInit2 = <String, dynamic>{
        "security": 42,
      };

      expect(
        () async => await servient.produce(exposedThingInit2),
        throwsA(isA<FormatException>()),
      );
    },
  );

  test(
    "should fill in missing values during the expansion of ExposedThingInits",
    () async {
      final servient = InternalServient();

      final exposedThingInit = <String, dynamic>{};

      final exposedThing = await servient.produce(exposedThingInit);

      expect(
        exposedThing.thingDescription.security,
        ["nosec_sc"],
      );

      final securityDefinitions =
          exposedThing.thingDescription.securityDefinitions;

      expect(securityDefinitions.length, 1);
      expect(securityDefinitions["nosec_sc"], isA<NoSecurityScheme>());

      expect(exposedThing.thingDescription.title, "Exposed Thing");
      expect(exposedThing.thingDescription.id, matches("urn:uuid:"));

      final context = exposedThing.thingDescription.context;
      expect(context.contextEntries.length, 1);
      expect(
        context.contextEntries[0],
        SingleContextEntry(Uri.parse("https://www.w3.org/2022/wot/td/v1.1")),
      );
    },
  );

  test(
    "should support ExposedThingInits with both single values and arrays for "
    "security",
    () async {
      final servient = InternalServient();

      final exposedThingInits = [
        <String, dynamic>{
          "security": "basic_sc",
          "securityDefinitions": {
            "basic_sc": {
              "scheme": "basic",
            },
          },
        },
        <String, dynamic>{
          "security": ["basic_sc"],
          "securityDefinitions": {
            "basic_sc": {
              "scheme": "basic",
            },
          },
        },
      ];

      for (final exposedThingInit in exposedThingInits) {
        final exposedThing = await servient.produce(exposedThingInit);

        expect(
          exposedThing.thingDescription.security,
          ["basic_sc"],
        );
      }
    },
  );
}
