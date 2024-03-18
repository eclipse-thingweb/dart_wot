// Copyright 2023 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dart_wot/core.dart";
import "package:test/test.dart";

const testUriScheme = "test";

class MockedProtocolClientFactory implements ProtocolClientFactory {
  @override
  Future<ProtocolClient> createClient() {
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
      final servient = Servient(
        clientFactories: [
          MockedProtocolClientFactory(),
        ],
      );

      expect(servient.clientSchemes, [testUriScheme]);
    });

    test(
      "should allow for adding and removing a ProtocolClientFactory at runtime",
      () {
        final servient = Servient()
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
      final servient = Servient();

      expect(
        () => servient.createClient(testUriScheme),
        throwsA(isA<DartWotException>()),
      );
    },
  );
}
