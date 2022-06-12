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
        'title': 'Test Thing'
      };
      final dynamic exposedThing = await wot.produce(exposedThingInit);
      // ignore: avoid_dynamic_calls
      expect(exposedThing.id.startsWith('urn:uuid:'), true);
    });

    test('Parse Thing Description', () {
      const thingDescriptionJson = '''
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
            "test": "test",
            "hreflang": "de"
          },
          {
            "href": "https://example.org",
            "hreflang": ["de", "en"]
          }
        ],
        "securityDefinitions": {
          "nosec_sc": {
            "scheme": "nosec"
          }
        },
        "security": ["nosec_sc"]
      }
      ''';
      final parsedTd = ThingDescription(thingDescriptionJson);

      expect(parsedTd.title, 'Test Thing');

      final firstContextEntry = parsedTd.context[0];
      final secondContextEntry = parsedTd.context[1];

      expect(firstContextEntry.key, null);
      expect(firstContextEntry.value, 'http://www.w3.org/ns/td');
      expect(secondContextEntry.key, '@language');
      expect(secondContextEntry.value, 'de');

      expect(parsedTd.security, ['nosec_sc']);
      final securityDefinition = parsedTd.securityDefinitions['nosec_sc']!;
      expect(securityDefinition.scheme, 'nosec');

      final parsedLink = parsedTd.links[0];
      expect(parsedLink.href, Uri.parse('https://example.org'));
      expect(parsedLink.rel, 'test');
      expect(parsedLink.anchor, Uri.parse('https://example.org'));
      expect(parsedLink.type, 'test');
      expect(parsedLink.sizes, '42');
      expect(parsedLink.hreflang, ['de']);
      expect(parsedLink.additionalFields['test'], 'test');

      final secondParsedLink = parsedTd.links[1];
      expect(secondParsedLink.hreflang, ['de', 'en']);
    });

    test('Link Tests', () {
      final link = Link('https://example.org',
          type: 'test',
          rel: 'test',
          anchor: 'https://example.org',
          sizes: '42',
          additionalFields: <String, dynamic>{'test': 'test'},
          hreflang: ['de']);
      expect(link.href, Uri.parse('https://example.org'));
      expect(link.rel, 'test');
      expect(link.anchor, Uri.parse('https://example.org'));
      expect(link.hreflang, ['de']);
      expect(link.type, 'test');
      expect(link.sizes, '42');
      expect(link.additionalFields['test'], 'test');

      final link2 = Link('https://example.org');
      expect(link2.href, Uri.parse('https://example.org'));
      expect(link2.anchor, null);
      expect(link2.additionalFields, <String, dynamic>{});
    });
  });
}
