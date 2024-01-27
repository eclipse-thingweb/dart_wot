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

      final interactionOutput = InteractionOutput(
        content,
        contentSerdes,
        Form(Uri.parse("http://example.org")),
        const DataSchema(),
      );

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

      final interactionOutput = InteractionOutput(
        content,
        contentSerdes,
        Form(Uri.parse("http://example.org")),
        const DataSchema(),
      );

      final value1 = await interactionOutput.value();
      expect(value1, inputValue);

      final value2 = await interactionOutput.value();
      expect(value1, value2);
    });

    test(
        "throw a NotReadableException when calling the arrayBuffer() method "
        "twice", () async {
      final contentSerdes = ContentSerdes();
      final content = Content(
        "text/plain",
        const Stream.empty(),
      );

      final interactionOutput = InteractionOutput(
        content,
        contentSerdes,
        Form(Uri.parse("http://example.org")),
        const DataSchema(),
      );

      await interactionOutput.arrayBuffer();

      final result = interactionOutput.arrayBuffer();
      await expectLater(
        result,
        throwsA(
          isA<NotReadableException>(),
        ),
      );
    });
  });

  test(
      "throw a NotReadableException in the value() method when no schema is "
      "defined", () async {
    final contentSerdes = ContentSerdes();
    final content = Content(
      "text/plain",
      const Stream.empty(),
    );

    final interactionOutput = InteractionOutput(
      content,
      contentSerdes,
      Form(Uri.parse("http://example.org")),
      null,
    );

    final result = interactionOutput.value();
    await expectLater(
      result,
      throwsA(
        isA<NotReadableException>(),
      ),
    );
  });

  test("allow accessing the form field", () async {
    final contentSerdes = ContentSerdes();
    final content = Content(
      "text/plain",
      const Stream.empty(),
    );

    final uri = Uri.parse("http://example.org");

    final interactionOutput = InteractionOutput(
      content,
      contentSerdes,
      Form(uri),
      const DataSchema(),
    );

    expect(interactionOutput.form.href, uri);
  });
}
