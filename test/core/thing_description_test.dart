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

      expect(thingDescriptionJson, thingDescription.toJson());
    });

    test(
        "be able to be created via its constructor and converted to a "
        "Map<String, dynamic>", () {
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
        "properties": {
          "status": {
            "type": "string",
            "readOnly": true,
            "observable": true,
            "forms": [
              {
                "href": "https://example.org",
                "contentType": "application/cbor",
              }
            ],
          },
        },
      };

      final thingDescription = ThingDescription(
        context: Context(
          [
            SingleContextEntry(
              Uri.parse("https://www.w3.org/2022/wot/td/v1.1"),
            ),
            const StringMapContextEntry(
              "@language",
              "de",
            ),
          ],
        ),
        title: "Test Thing",
        security: const [
          "nosec_sc",
        ],
        securityDefinitions: const {
          "nosec_sc": NoSecurityScheme(),
        },
        properties: {
          "status": Property(
            forms: [
              Form(
                Uri.parse("https://example.org"),
                contentType: "application/cbor",
              ),
            ],
            observable: true,
            dataSchema: const DataSchema(
              type: "string",
              readOnly: true,
              writeOnly: false,
            ),
          ),
        },
      );

      expect(thingDescriptionJson, thingDescription.toJson());
    });

    test("throw a FormatException when it is invalid during parsing", () {
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
        throwsA(isA<FormatException>()),
      );
    });

    test("use the correct @context entry as the default prefix value", () {
      final thingDescription = {
        "@context": [
          "https://www.w3.org/2022/wot/td/v1.1",
        ],
        "title": "Invalid TD with missing security field.",
        "security": "nosec_sc",
        "securityDefinitions": {
          "nosec_sc": {"scheme": "nosec"},
        },
      }.toThingDescription();

      expect(
        thingDescription.prefixMapping.defaultPrefixValue,
        "https://www.w3.org/2022/wot/td/v1.1",
      );
    });

    test("reject invalid ComboSecuritySchemes", () {
      final invalidThingDescription1 = {
        "@context": [
          "https://www.w3.org/2022/wot/td/v1.1",
        ],
        "title": "Invalid TD with missing security field.",
        "security": "combo_sc",
        "securityDefinitions": {
          "combo_sc": {"scheme": "combo"},
        },
      };

      expect(
        invalidThingDescription1.toThingDescription,
        throwsFormatException,
      );

      final invalidThingDescription2 = {
        "@context": [
          "https://www.w3.org/2022/wot/td/v1.1",
        ],
        "title": "Invalid TD with missing security field.",
        "security": "combo_sc",
        "securityDefinitions": {
          "nosec_sc1": {"scheme": "nosec"},
          "nosec_sc2": {"scheme": "nosec"},
          "combo_sc": {
            "scheme": "combo",
            "oneOf": [
              "nosec_sc1",
              "nosec_sc2",
            ],
            "allOf": [
              "nosec_sc1",
              "nosec_sc2",
            ],
          },
        },
      };

      expect(
        invalidThingDescription2.toThingDescription,
        throwsFormatException,
      );

      final invalidThingDescription3 = {
        "@context": [
          "https://www.w3.org/2022/wot/td/v1.1",
        ],
        "title": "Invalid TD with missing security field.",
        "security": "combo_sc",
        "securityDefinitions": {
          "nosec_sc1": {"scheme": "nosec"},
          "combo_sc": {
            "scheme": "combo",
            "oneOf": [
              "nosec_sc1",
            ],
          },
        },
      };

      expect(
        invalidThingDescription3.toThingDescription,
        throwsFormatException,
      );

      final invalidThingDescription4 = {
        "@context": [
          "https://www.w3.org/2022/wot/td/v1.1",
        ],
        "title": "Invalid TD with missing security field.",
        "security": "combo_sc",
        "securityDefinitions": {
          "nosec_sc1": {"scheme": "nosec"},
          "combo_sc": {
            "scheme": "combo",
            "allOf": [
              "nosec_sc1",
            ],
          },
        },
      };

      expect(
        invalidThingDescription4.toThingDescription,
        throwsFormatException,
      );
    });
  });
}
