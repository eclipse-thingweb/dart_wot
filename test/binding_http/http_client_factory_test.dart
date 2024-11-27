// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dart_wot/binding_http.dart";
import "package:dart_wot/core.dart";
import "package:test/test.dart";

void main() {
  group("HttpClientFactory should", () {
    test("indicate correctly whether an operation is supported", () {
      final httpClientFactory = HttpClientFactory();

      final testVector = [
        (
          expectedResult: true,
          subprotocol: null,
        ),
        (
          expectedResult: true,
          subprotocol: "sse",
        ),
        (
          expectedResult: false,
          subprotocol: "foobar",
        ),
      ];

      for (final testCase in testVector) {
        expect(
          httpClientFactory.supportsOperation(
            OperationType.invokeaction,
            testCase.subprotocol,
          ),
          testCase.expectedResult,
        );
      }
    });
  });
}
