// Copyright 2023 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:convert';

import 'package:dart_wot/dart_wot.dart';
import 'package:dart_wot/src/core/content.dart';
import 'package:test/test.dart';

void main() {
  group('Content should', () {
    group('be able to be instantiated using fromInteractionInput() with', () {
      test('null', () async {
        final contentSerdes = ContentSerdes();
        final content = Content.fromInteractionInput(
          null,
          'application/json',
          contentSerdes,
          null,
        );

        expect(await content.body.isEmpty, isTrue);
      });

      test('a DataSchemaValueInput', () async {
        final contentSerdes = ContentSerdes();
        const inputValue = 'foo';
        final input =
            DataSchemaValueInput(DataSchemaValue.fromString(inputValue));

        final content = Content.fromInteractionInput(
          input,
          'application/json',
          contentSerdes,
          null,
        );

        expect(await content.toByteList(), [34, 102, 111, 111, 34]);
      });

      test('a StreamInput', () async {
        final contentSerdes = ContentSerdes();
        const inputValue = '"foo"';
        final byteList = [utf8.encode(inputValue)];
        final input = StreamInput(Stream.fromIterable(byteList));

        final content = Content.fromInteractionInput(
          input,
          'application/json',
          contentSerdes,
          null,
        );

        expect(await content.toByteList(), [34, 102, 111, 111, 34]);
      });
    });
  });
}
