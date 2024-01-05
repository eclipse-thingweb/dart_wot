// Copyright 2023 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:convert";

import "package:dart_wot/core.dart" hide InteractionOutput;
import "package:dart_wot/src/core/implementation/interaction_output.dart";
import "package:test/test.dart";

void main() {
  group("InteractionOutput should", () {
    test("output the correct value", () async {
      const inputValue = "foo";
      final input = utf8.encode(inputValue);

      final contentSerdes = ContentSerdes();
      final content = Content(
        "text/plain",
        Stream.fromIterable([
          input,
        ]),
      );

      final interactionOutput = InteractionOutput(content, contentSerdes);

      final value1 = await interactionOutput.value();
      expect(value1, inputValue);

      // Should return the same value
      final value2 = await interactionOutput.value();
      expect(value2, inputValue);
    });

    test("output the same value when calling value() twice", () async {
      const inputValue = "bar";
      final input = utf8.encode(inputValue);

      final contentSerdes = ContentSerdes();
      final content = Content(
        "text/plain",
        Stream.fromIterable([
          input,
        ]),
      );

      final interactionOutput = InteractionOutput(content, contentSerdes);

      final value1 = await interactionOutput.value();
      expect(value1, inputValue);

      final value2 = await interactionOutput.value();
      expect(value1, value2);
    });
  });
}
