// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dart_wot/binding_mqtt.dart";
import "package:dart_wot/core.dart";
import "package:test/test.dart";

void main() {
  group("MqttClientFactory should", () {
    test("indicate correctly whether an operation is supported", () {
      final coapClientFactory = MqttClientFactory();

      final testVector = [
        (
          expectedResult: false,
          operationTypes: OperationType.values,
          subprotocol: "foobar",
        ),
        (
          expectedResult: true,
          operationTypes: OperationType.values,
          subprotocol: null,
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
