// Copyright 2022 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import 'package:dart_wot/dart_wot.dart';
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
        "securityDefinitions": {
          "nosec_sc": {
            "scheme": "nosec"
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

      expect(parsedTd.title, "Test Thing");

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
    });
  });
}
