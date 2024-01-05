// Copyright 2023 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:convert";

import "package:dart_wot/core.dart";
import "package:dart_wot/src/core/implementation/codecs/cbor_codec.dart";
import "package:dart_wot/src/core/implementation/codecs/json_codec.dart"
    as json_codec;
import "package:dart_wot/src/core/implementation/codecs/text_codec.dart";
import "package:test/test.dart";

void main() {
  group("TextCodec should", () {
    test("convert bytes to values and back", () {
      final textCodec = TextCodec();

      const testValue = "foo";
      final testInput = utf8.encode(testValue);

      final convertedValue = textCodec.bytesToValue(testInput, null, {});
      expect(convertedValue?.value, testValue);

      final convertedBytes = textCodec.valueToBytes(convertedValue, null, {});

      expect(convertedBytes, testInput);

      final convertedNullValue = textCodec.valueToBytes(null, null, {});
      expect(convertedNullValue, []);
    });

    test("reject unknown charsets", () {
      final textCodec = TextCodec();

      const charsetParameters = {"charset": "foobar"};

      expect(
        () =>
            textCodec.bytesToValue(utf8.encode("foo"), null, charsetParameters),
        throwsFormatException,
      );

      expect(
        () => textCodec.valueToBytes(
          DataSchemaValue.fromNull(),
          null,
          charsetParameters,
        ),
        throwsFormatException,
      );
    });
  });

  group("JsonCodec should", () {
    test("convert bytes to values and back", () {
      final jsonCodec = json_codec.JsonCodec();

      const testValue = "foo";
      final testInput = utf8.encode('"$testValue"');

      final convertedValue = jsonCodec.bytesToValue(testInput, null, {});
      expect(convertedValue?.value, testValue);

      final convertedBytes = jsonCodec.valueToBytes(convertedValue, null, {});

      expect(convertedBytes, testInput);

      final convertedNullValue = jsonCodec.valueToBytes(null, null, {});
      expect(convertedNullValue, []);
    });
  });

  group("CborCodec should", () {
    test("convert bytes to values and back", () {
      final cborCodec = CborCodec();
      const testValue = {
        "foo": ["bar", "baz"],
      };

      final convertedBytes = cborCodec
          .valueToBytes(DataSchemaValue.fromObject(testValue), null, {});

      expect(
        convertedBytes,
        [161, 99, 102, 111, 111, 130, 99, 98, 97, 114, 99, 98, 97, 122],
      );

      final convertedValue = cborCodec.bytesToValue(convertedBytes, null, {});
      expect(convertedValue?.value, testValue);

      final convertedNullValue = cborCodec.valueToBytes(null, null, {});
      expect(convertedNullValue, []);
    });
  });
}
