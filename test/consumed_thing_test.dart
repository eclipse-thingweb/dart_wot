// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/dart_wot.dart';
import 'package:dart_wot/src/definitions/security/basic_security_scheme.dart';
import 'package:test/test.dart';

void main() {
  group('Consumed Thing Tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Parse Interaction Affordances', () async {
      final thingDescriptionJson = '''
      {
        "@context": ["http://www.w3.org/ns/td"],
        "title": "Test Thing",
        "titles": {
          "en": "Test Thing"
        },
        "description": "A Test Thing used for Testing.",
        "descriptions": {
          "en": "A Test Thing used for Testing."
        },
        "securityDefinitions": {
          "nosec_sc": {
            "scheme": "nosec"
          },
          "basic_sc": {
            "scheme": "basic",
            "description": "Test"
          }
        },
        "security": "nosec_sc",
        "properties": {
          "status": {
            "title": "Status",
            "titles": {
              "en": "Status"
            },
            "description": "Status of this Lamp",
            "descriptions": {
              "en": "Status of this Lamp"
            },
            "forms": [
              {
                "href": "coap://example.org"
              }
            ]
          }
        },
        "actions": {
          "toggle": {
            "title": "Toggle",
            "titles": {
              "en": "Toggle"
            },
            "description": "Toggle this Lamp",
            "descriptions": {
              "en": "Toggle this Lamp"
            },
            "forms": [
              {
                "href": "coap://example.org"
              }
            ]
          }
        },
        "events": {
          "overheating": {
            "title": "Overheating",
            "titles": {
              "en": "Overheating"
            },
            "description": "Overheating of this Lamp",
            "descriptions": {
              "en": "Overheating of this Lamp"
            },
            "forms": [
              {
                "href": "coap://example.org"
              }
            ]
          }
        }
      }
      ''';

      final parsedTd = ThingDescription(thingDescriptionJson);

      final security = parsedTd.security;
      expect(security, ["nosec_sc"]);

      expect(parsedTd.title, "Test Thing");
      expect(parsedTd.titles, {"en": "Test Thing"});
      expect(parsedTd.description, "A Test Thing used for Testing.");
      expect(parsedTd.descriptions, {"en": "A Test Thing used for Testing."});

      final statusProperty = parsedTd.properties["status"];
      expect(statusProperty!.title, "Status");
      expect(statusProperty.titles!["en"], "Status");
      expect(statusProperty.description, "Status of this Lamp");
      expect(statusProperty.descriptions!["en"], "Status of this Lamp");

      final toggleAction = parsedTd.actions["toggle"];
      expect(toggleAction!.title, "Toggle");
      expect(toggleAction.titles!["en"], "Toggle");
      expect(toggleAction.description, "Toggle this Lamp");
      expect(toggleAction.descriptions!["en"], "Toggle this Lamp");

      final eventAction = parsedTd.events["overheating"];
      expect(eventAction!.title, "Overheating");
      expect(eventAction.titles!["en"], "Overheating");
      expect(eventAction.description, "Overheating of this Lamp");
      expect(eventAction.descriptions!["en"], "Overheating of this Lamp");

      expect(parsedTd.securityDefinitions["basic_sc"] is BasicSecurityScheme,
          true);
      expect(parsedTd.securityDefinitions["basic_sc"]?.description, "Test");
    });
  });
}
