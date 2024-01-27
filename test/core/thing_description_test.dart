// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dart_wot/core.dart";
import "package:test/test.dart";

void main() {
  group("ThingDescription should", () {
    test("be able to be instantiated from a ThingModel", () {
      final json = {
        "title": "Test TM",
      };
      final thingModel = ThingModel.fromJson(json);

      // TODO(JKRhb): Implement fromThingModel constructor
      expect(
        () => ThingDescription.fromThingModel(thingModel),
        throwsUnimplementedError,
      );
    });
  });

  test("be able to be converted to a Map<String, dynamic>", () {
    const thingDescriptionJson = {
      "@context": [
        "https://www.w3.org/2022/wot/td/v1.1",
        {"@language": "de"},
      ],
      "title": "Test Thing",
      "securityDefinitions": {
        "nosec_sc": {"scheme": "nosec"},
      },
      "security": ["nosec_sc"],
    };
    final thingDescription = thingDescriptionJson.toThingDescription();

    // TODO(JKRhb): Implement toJson method
    expect(
      thingDescription.toJson,
      throwsUnimplementedError,
    );
  });

  test("should throw a ValidationException when it is invalid during parsing",
      () {
    const thingDescriptionJson = {
      "@context": [
        "https://www.w3.org/2022/wot/td/v1.1",
      ],
      "title": "Invalid TD with missing security field.",
      "securityDefinitions": {
        "nosec_sc": {"scheme": "nosec"},
      },
    };

    expect(
      () => ThingDescription.fromJson(thingDescriptionJson),
      throwsA(isA<ValidationException>()),
    );
  });
}
