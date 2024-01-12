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
  group("Servient Tests", () {
    test("Should accept a ProtocolClientFactory list as constructor argument",
        () {
      final servient = Servient(
        clientFactories: [
          MockedProtocolClientFactory(),
        ],
      );

      expect(servient.clientSchemes, [testUriScheme]);
      expect(servient.hasClientFor(testUriScheme), true);
    });

    test(
      "Should allow for adding and removing a ProtocolClientFactory at runtime",
      () {
        final servient = Servient()
          ..addClientFactory(MockedProtocolClientFactory());

        expect(servient.hasClientFor(testUriScheme), true);

        servient.removeClientFactory(testUriScheme);

        expect(servient.hasClientFor(testUriScheme), false);
        expect(servient.clientSchemes.length, 0);
      },
    );
  });
}
