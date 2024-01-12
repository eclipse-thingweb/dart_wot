// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dart_wot/binding_coap.dart";
import "package:dart_wot/core.dart";
import "package:test/test.dart";

void main() {
  group("CoapClientFactory should", () {
    test("indicate correctly whether an operation is supported", () {
      final coapClientFactory = CoapClientFactory();

      const observeOperations = [
        OperationType.observeproperty,
        OperationType.unobserveproperty,
        OperationType.subscribeevent,
        OperationType.unsubscribeevent,
      ];
      final otherOperations = OperationType.values
          .where((operationType) => !observeOperations.contains(operationType));

      final testVector = [
        (
          expectedResult: true,
          operationTypes: observeOperations,
          subprotocol: "cov:observe",
        ),
        (
          expectedResult: false,
          operationTypes: observeOperations,
          subprotocol: null,
        ),
        (
          expectedResult: true,
          operationTypes: otherOperations,
          subprotocol: null,
        ),
        (
          expectedResult: false,
          operationTypes: otherOperations,
          subprotocol: "cov:observe",
        ),
        (
          expectedResult: false,
          operationTypes: OperationType.values,
          subprotocol: "foobar",
        ),
      ];

      for (final testCase in testVector) {
        for (final operationType in testCase.operationTypes) {
          expect(
            coapClientFactory.supportsOperation(
              operationType,
              testCase.subprotocol,
            ),
            testCase.expectedResult,
          );
        }
      }
    });
  });
}
