// Copyright 2023 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dart_wot/scripting_api.dart";
import "package:test/test.dart";

void main() {
  group("InteractionInput", () {
    group("should be able to be instantiated from", () {
      test("null", () {
        final interactionInput = InteractionInput.fromNull();

        expect(interactionInput, isA<DataSchemaValueInput>());

        expect(
          (interactionInput as DataSchemaValueInput).dataSchemaValue,
          isA<NullValue>(),
        );

        final alternativeInteractionInput = null.asInteractionInput();
        expect(interactionInput, alternativeInteractionInput);
        expect(interactionInput.hashCode, alternativeInteractionInput.hashCode);
      });

      test("a String", () {
        const testValue = "foo";
        final interactionInput = InteractionInput.fromString(testValue);

        expect(interactionInput, isA<DataSchemaValueInput>());

        expect(
          (interactionInput as DataSchemaValueInput).dataSchemaValue,
          isA<StringValue>(),
        );

        expect(
          interactionInput.dataSchemaValue,
          DataSchemaValue.fromString(testValue),
        );

        final alternativeInteractionInput = testValue.asInteractionInput();
        expect(interactionInput, alternativeInteractionInput);
        expect(interactionInput.hashCode, alternativeInteractionInput.hashCode);
      });

      test("an Integer", () {
        const testValue = 42;
        final interactionInput = InteractionInput.fromInteger(testValue);

        expect(interactionInput, isA<DataSchemaValueInput>());

        expect(
          (interactionInput as DataSchemaValueInput).dataSchemaValue,
          isA<IntegerValue>(),
        );

        expect(
          interactionInput.dataSchemaValue,
          DataSchemaValue.fromInteger(testValue),
        );

        final alternativeInteractionInput = testValue.asInteractionInput();
        expect(interactionInput, alternativeInteractionInput);
        expect(interactionInput.hashCode, alternativeInteractionInput.hashCode);
      });

      test("a Number", () {
        const testValue = 42.0;
        final interactionInput = InteractionInput.fromNumber(testValue);

        expect(interactionInput, isA<DataSchemaValueInput>());

        expect(
          (interactionInput as DataSchemaValueInput).dataSchemaValue,
          isA<NumberValue>(),
        );

        expect(
          interactionInput.dataSchemaValue,
          DataSchemaValue.fromNumber(testValue),
        );

        final alternativeInteractionInput = testValue.asInteractionInput();
        expect(interactionInput, alternativeInteractionInput);
        expect(interactionInput.hashCode, alternativeInteractionInput.hashCode);
      });

      test("a Boolean", () {
        const testValue = true;
        final interactionInput = InteractionInput.fromBoolean(testValue);

        expect(interactionInput, isA<DataSchemaValueInput>());

        expect(
          (interactionInput as DataSchemaValueInput).dataSchemaValue,
          isA<BooleanValue>(),
        );

        expect(
          interactionInput.dataSchemaValue,
          DataSchemaValue.fromBoolean(testValue),
        );

        final alternativeInteractionInput = testValue.asInteractionInput();
        expect(interactionInput, alternativeInteractionInput);
        expect(interactionInput.hashCode, alternativeInteractionInput.hashCode);
      });

      test("an Array", () {
        const testValue = [true, 42, "foo"];
        final interactionInput = InteractionInput.fromArray(testValue);

        expect(interactionInput, isA<DataSchemaValueInput>());

        expect(
          (interactionInput as DataSchemaValueInput).dataSchemaValue,
          isA<ArrayValue>(),
        );

        expect(
          interactionInput.dataSchemaValue,
          DataSchemaValue.fromArray(testValue),
        );

        expect(
          interactionInput.dataSchemaValue.hashCode,
          DataSchemaValue.fromArray(testValue).hashCode,
        );

        final alternativeInteractionInput = testValue.asInteractionInput();
        expect(interactionInput, alternativeInteractionInput);
        expect(interactionInput.hashCode, alternativeInteractionInput.hashCode);
      });

      test("an Object", () {
        const testValue = <String, Object?>{
          "bool": true,
          "int": 42,
          "string": "foo",
          "number": 42.0,
          "null": null,
          "array": [true, "bar", 42],
          "object": {
            "string": "baz",
          },
        };
        final interactionInput = InteractionInput.fromObject(testValue);

        expect(interactionInput, isA<DataSchemaValueInput>());

        expect(
          (interactionInput as DataSchemaValueInput).dataSchemaValue,
          isA<ObjectValue>(),
        );

        expect(
          interactionInput.dataSchemaValue,
          DataSchemaValue.fromObject(testValue),
        );

        expect(
          interactionInput.dataSchemaValue.hashCode,
          DataSchemaValue.fromObject(testValue).hashCode,
        );

        final alternativeInteractionInput = testValue.asInteractionInput();
        expect(interactionInput, alternativeInteractionInput);
        expect(interactionInput.hashCode, alternativeInteractionInput.hashCode);
      });

      test("a byte stream", () {
        final testValue = Stream.fromIterable([
          [0, 1, 2],
          [3, 4, 5],
        ]);
        final interactionInput = InteractionInput.fromStream(testValue);

        expect(interactionInput, isA<StreamInput>());
      });
    });
  });
}
