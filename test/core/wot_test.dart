// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dart_wot/core.dart";
import "package:test/test.dart";

void main() {
  group("WoT should", () {
    test("not throw an execption when consuming the same TD twice", () async {
      const thingDescriptionJson = {
        "@context": "https://www.w3.org/2022/wot/td/v1.1",
        "title": "Test Thing",
        "securityDefinitions": {
          "nosec_sc": {"scheme": "nosec"},
        },
        "security": ["nosec_sc"],
      };
      final thingDescription = thingDescriptionJson.toThingDescription();

      final wot = await Servient().start();

      final firstConsumedThing = await wot.consume(thingDescription);
      final secondConsumedThing = await wot.consume(thingDescription);
      expect(firstConsumedThing != secondConsumedThing, isTrue);
    });

    test(
        "throw an execption when producing an ExposedThing "
        "from the same TD twice", () async {
      const exposedThingInit = {
        "@context": "https://www.w3.org/2022/wot/td/v1.1",
        "title": "Test Thing",
        "securityDefinitions": {
          "nosec_sc": {"scheme": "nosec"},
        },
        "security": ["nosec_sc"],
        "id": "urn:test",
      };

      final wot = await Servient().start();

      await wot.produce(exposedThingInit);
      final result = wot.produce(exposedThingInit);
      await expectLater(result, throwsA(isA<DartWotException>()));
    });
  });
}
