// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dart_wot/dart_wot.dart";
import "package:dart_wot/src/binding_mqtt/mqtt_extensions.dart";
import "package:dart_wot/src/definitions/validation/validation_exception.dart";
import "package:test/test.dart";

void main() {
  group("MQTT Binding Extensions should", () {
    test("reject forms with unknown QoS values", () {
      const id = "urn:foobar";
      const href = "mqtt://example.org/test";
      final thingDescription = ThingDescription.fromJson(
        const {
          "@context": [
            "https://www.w3.org/2022/wot/td/v1.1",
            {
              "mqv": "http://www.example.org/mqtt-binding#",
            }
          ],
          "title": "Test TD",
          "id": id,
          "properties": {
            "test": {
              "forms": [
                {
                  "href": href,
                  "mqv:qos": "foobar",
                }
              ],
            },
          },
          "security": ["nosec_sc"],
          "securityDefinitions": {
            "nosec_sc": {
              "scheme": "nosec",
            },
          },
        },
      );
      final affordance = thingDescription.properties?["test"];

      final augmentedForm = AugmentedForm(
        affordance!.forms.first,
        affordance,
        thingDescription,
        const {},
      );

      expect(
        () => augmentedForm.qualityOfService,
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
