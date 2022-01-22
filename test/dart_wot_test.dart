// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/dart_wot.dart';
import 'package:dart_wot/src/definitions/link.dart';
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
        },
        "links": [
          {
            "href": "https://example.org",
            "rel": "test",
            "anchor": "https://example.org",
            "type": "test",
            "sizes": "42",
            "test": "test"
          }
        ]
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

      final parsedLink = parsedTd.links[0];
      expect(parsedLink.href, Uri.parse("https://example.org"));
      expect(parsedLink.rel, "test");
      expect(parsedLink.anchor, Uri.parse("https://example.org"));
      expect(parsedLink.type, "test");
      expect(parsedLink.sizes, "42");
      expect(parsedLink.additionalFields["test"], "test");
    });

    test('Link Tests', () {
      final link = Link("https://example.org",
          type: "test",
          rel: "test",
          anchor: "https://example.org",
          sizes: "42",
          additionalFields: <String, dynamic>{"test": "test"});
      expect(link.href, Uri.parse("https://example.org"));
      expect(link.rel, "test");
      expect(link.anchor, Uri.parse("https://example.org"));
      expect(link.type, "test");
      expect(link.sizes, "42");
      expect(link.additionalFields["test"], "test");

      final link2 = Link("https://example.org");
      expect(link2.href, Uri.parse("https://example.org"));
      expect(link2.anchor, null);
      expect(link2.additionalFields, <String, dynamic>{});
    });
  });
}
