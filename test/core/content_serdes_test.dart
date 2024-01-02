// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:curie/curie.dart";
import "package:dart_wot/src/core/codecs/json_codec.dart";
import "package:dart_wot/src/core/content.dart";
import "package:dart_wot/src/core/content_serdes.dart";
import "package:dart_wot/src/definitions/data_schema.dart";
import "package:dart_wot/src/scripting_api/data_schema_value.dart";
import "package:test/test.dart";

Content _getTestContent(String input) {
  return Content("application/json", Stream<List<int>>.value(input.codeUnits));
}

void main() {
  group("ContentSerdes should", () {
    test("validate Content", () async {
      final contentSerdes = ContentSerdes();

      final testContent1 = _getTestContent("42");
      final successfulSchema = DataSchema.fromJson(
        const <String, dynamic>{"type": "number"},
        PrefixMapping(),
      );

      expect(
        await contentSerdes.contentToValue(testContent1, successfulSchema),
        DataSchemaValue.fromInteger(42),
      );

      final testContent2 = _getTestContent("42");
      final failingSchema = DataSchema.fromJson(
        const <String, dynamic>{"type": "string"},
        PrefixMapping(),
      );

      expect(
        contentSerdes.contentToValue(testContent2, failingSchema),
        throwsA(const TypeMatcher<ContentSerdesException>()),
      );

      expect(
        () => contentSerdes.valueToContent(
          DataSchemaValue.tryParse(42),
          failingSchema,
        ),
        throwsA(const TypeMatcher<ContentSerdesException>()),
      );

      final testContent3 = _getTestContent("");
      expect(
        await contentSerdes.contentToValue(testContent3, null),
        null,
      );
    });
    test("support registration of new Codecs", () async {
      final contentSerdes = ContentSerdes();

      expect(
        contentSerdes.supportedMediaTypes,
        [
          "application/json",
          "application/cbor",
          "application/link-format",
          "text/plain",
        ],
      );

      expect(
        contentSerdes.offeredMediaTypes,
        ["application/json", "application/cbor"],
      );

      expect(
        () => contentSerdes.addOfferedMediaType("application/xml"),
        throwsArgumentError,
      );

      contentSerdes.addOfferedMediaType("application/td+json; charset=utf-8");

      expect(
        contentSerdes.offeredMediaTypes,
        [
          "application/json",
          "application/cbor",
          "application/td+json; charset=utf-8",
        ],
      );

      contentSerdes.removeOfferedMediaType("application/json");

      expect(
        contentSerdes.offeredMediaTypes,
        [
          "application/cbor",
          "application/td+json; charset=utf-8",
        ],
      );

      contentSerdes
        ..assignCodec("application/xml", JsonCodec())
        ..addOfferedMediaType("application/xml");

      expect(
        contentSerdes.supportedMediaTypes,
        [
          "application/json",
          "application/cbor",
          "application/link-format",
          "text/plain",
          "application/xml",
        ],
      );

      expect(
        contentSerdes.offeredMediaTypes,
        [
          "application/cbor",
          "application/td+json; charset=utf-8",
          "application/xml",
        ],
      );

      expect(
        () => contentSerdes.assignCodec("foo", JsonCodec()),
        throwsArgumentError,
      );
    });

    test("return a Content object with an empty Stream for undefined values",
        () async {
      final contentSerdes = ContentSerdes();
      final content = contentSerdes.valueToContent(null, null);

      expect(await content.body.isEmpty, isTrue);
    });

    test("reject undefined DataSchemaValues if a DataSchema is given",
        () async {
      final contentSerdes = ContentSerdes();

      expect(
        () => contentSerdes.valueToContent(
          null,
          // FIXME(JKRhb): Should not be necessary to use fromJson here
          DataSchema.fromJson(const {"type": "object"}, PrefixMapping()),
        ),
        throwsA(isA<ContentSerdesException>()),
      );
    });

    test("convert DataSchemaValues to Content", () async {
      final contentSerdes = ContentSerdes();
      const inputValue = "foo";

      final content = contentSerdes.valueToContent(
        DataSchemaValue.fromString(inputValue),
        null,
      );

      expect(await content.toByteList(), [34, 102, 111, 111, 34]);
      expect(content.type, "application/json");
    });
  });
}
