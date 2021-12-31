// Copyright 2021 The NAMIB Project Developers
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

// TODO(JKRhb): Add proper tests

void main() {
  group('Exposed Thing Tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Parse incomplete Thing Description', () async {
      final servient = Servient();
      final wot = await servient.start();
      final Map<String, dynamic> exposedThingInit = <String, dynamic>{
        "title": "Test Thing"
      };
      final exposedThing = await wot.produce(exposedThingInit);
      expect(exposedThing.id!.startsWith("urn:uuid:"), true);
    });

    test('Parse Thing Description', () {
      final thingDescriptionJson = '''
      {
        "@context": ["http://www.w3.org/ns/td", {"@language": "de"}],
        "title": "Test Thing",
        "properties": {
          "status": {
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

      final firstContextEntry = parsedTd.context[0];
      final secondContextEntry = parsedTd.context[1];

      expect(firstContextEntry.key, null);
      expect(firstContextEntry.value, "http://www.w3.org/ns/td");
      expect(secondContextEntry.key, "@language");
      expect(secondContextEntry.value, "de");
    });
  });
}
