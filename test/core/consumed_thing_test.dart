// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/dart_wot.dart';
import 'package:dart_wot/src/definitions/security/apikey_security_scheme.dart';
import 'package:dart_wot/src/definitions/security/basic_security_scheme.dart';
import 'package:dart_wot/src/definitions/security/bearer_security_scheme.dart';
import 'package:dart_wot/src/definitions/security/combo_security_scheme.dart';
import 'package:dart_wot/src/definitions/security/digest_security_scheme.dart';
import 'package:dart_wot/src/definitions/security/no_security_scheme.dart';
import 'package:dart_wot/src/definitions/security/oauth2_security_scheme.dart';
import 'package:dart_wot/src/definitions/security/psk_security_scheme.dart';
import 'package:dart_wot/src/definitions/validation/validation_exception.dart';
import 'package:test/test.dart';

void main() {
  group('Consumed Thing Tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Parse Interaction Affordances', () async {
      const thingDescriptionJson = '''
      {
        "@context": [
          "http://www.w3.org/ns/td",
          {
            "coap": "http://www.example.org/coap-binding#"
          }
        ],
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
            "scheme": "nosec",
            "proxy": "http://example.org",
            "@type": "Test"
          },
          "basic_sc": {
            "scheme": "basic",
            "in": "query",
            "description": "Test"
          },
          "psk_sc": {
            "scheme": "psk",
            "identity": "Test"
          },
          "apikey_sc": {
            "scheme": "apikey",
            "name": "Test",
            "in": "body"
          },
          "digest_sc": {
            "scheme": "digest",
            "name": "Test",
            "in": "cookie",
            "qop": "auth-int"
          },
          "bearer_sc": {
            "scheme": "bearer",
            "authorization": "http://example.org",
            "name": "Test",
            "alg": "ES256",
            "format": "jws",
            "in": "uri"
          },
          "oauth2_sc": {
            "scheme": "oauth2",
            "authorization": "http://example.org",
            "token": "http://example.org",
            "refresh": "http://example.org",
            "scopes": "test",
            "flow": "client"
          },
          "combo_sc1": {
            "scheme": "combo",
            "allOf": ["digest_sc", "apikey_sc"]
          },
          "combo_sc2": {
            "scheme": "combo",
            "oneOf": ["oauth2_sc", "bearer_sc"]
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
      expect(security, ['nosec_sc']);

      expect(parsedTd.title, 'Test Thing');
      expect(parsedTd.titles, {'en': 'Test Thing'});
      expect(parsedTd.description, 'A Test Thing used for Testing.');
      expect(parsedTd.descriptions, {'en': 'A Test Thing used for Testing.'});

      final statusProperty = parsedTd.properties['status'];
      expect(statusProperty!.title, 'Status');
      expect(statusProperty.titles!['en'], 'Status');
      expect(statusProperty.description, 'Status of this Lamp');
      expect(statusProperty.descriptions!['en'], 'Status of this Lamp');

      final toggleAction = parsedTd.actions['toggle'];
      expect(toggleAction!.title, 'Toggle');
      expect(toggleAction.titles!['en'], 'Toggle');
      expect(toggleAction.description, 'Toggle this Lamp');
      expect(toggleAction.descriptions!['en'], 'Toggle this Lamp');

      final eventAction = parsedTd.events['overheating'];
      expect(eventAction!.title, 'Overheating');
      expect(eventAction.titles!['en'], 'Overheating');
      expect(eventAction.description, 'Overheating of this Lamp');
      expect(eventAction.descriptions!['en'], 'Overheating of this Lamp');

      final nosecSc = parsedTd.securityDefinitions['nosec_sc'];
      expect(nosecSc is NoSecurityScheme, true);
      expect(nosecSc?.proxy, Uri.parse('http://example.org'));
      expect(nosecSc?.jsonLdType, ['Test']);

      final basicSc = parsedTd.securityDefinitions['basic_sc'];
      expect(basicSc is BasicSecurityScheme, true);
      expect(basicSc?.description, 'Test');
      expect((basicSc as BasicSecurityScheme?)!.in_, 'query');

      final pskSc = parsedTd.securityDefinitions['psk_sc'];
      expect(pskSc is PskSecurityScheme, true);
      expect((pskSc as PskSecurityScheme?)!.identity, 'Test');

      final apikeySc = parsedTd.securityDefinitions['apikey_sc'];
      expect(apikeySc is ApiKeySecurityScheme, true);
      expect((apikeySc as ApiKeySecurityScheme?)!.name, 'Test');
      expect(apikeySc!.in_, 'body');

      final digestSc = parsedTd.securityDefinitions['digest_sc'];
      expect(digestSc is DigestSecurityScheme, true);
      expect((digestSc as DigestSecurityScheme?)!.name, 'Test');
      expect(digestSc!.in_, 'cookie');
      expect(digestSc.qop, 'auth-int');

      final bearerSc = parsedTd.securityDefinitions['bearer_sc'];
      expect(bearerSc is BearerSecurityScheme, true);
      expect(
        (bearerSc as BearerSecurityScheme?)!.authorization,
        'http://example.org',
      );
      expect(bearerSc!.name, 'Test');
      expect(bearerSc.alg, 'ES256');
      expect(bearerSc.format, 'jws');
      expect(bearerSc.in_, 'uri');

      final oauth2Sc = parsedTd.securityDefinitions['oauth2_sc'];
      expect(oauth2Sc is OAuth2SecurityScheme, true);
      expect(
        (oauth2Sc as OAuth2SecurityScheme?)!.authorization,
        'http://example.org',
      );
      expect(oauth2Sc!.refresh, 'http://example.org');
      expect(oauth2Sc.token, 'http://example.org');
      expect(oauth2Sc.scopes, ['test']);
      expect(oauth2Sc.flow, 'client');

      final comboSc1 = parsedTd.securityDefinitions['combo_sc1'];
      expect(comboSc1 is ComboSecurityScheme, true);
      expect(
        (comboSc1 as ComboSecurityScheme?)!.allOf,
        ['digest_sc', 'apikey_sc'],
      );
      expect(comboSc1!.oneOf, null);

      final comboSc2 = parsedTd.securityDefinitions['combo_sc2'];
      expect(comboSc2 is ComboSecurityScheme, true);
      expect(
        (comboSc2 as ComboSecurityScheme?)!.oneOf,
        ['oauth2_sc', 'bearer_sc'],
      );
      expect(comboSc2!.allOf, null);
    });
  });

  test(
    'Use of URI Template Variables',
    () async {
      const thingDescriptionJson = '''
      {
        "@context": ["http://www.w3.org/ns/td"],
        "title": "Test Thing",
        "base": "https://httpbin.org",
        "securityDefinitions": {
          "nosec_sc": {
            "scheme": "nosec"
          }
        },
        "security": "nosec_sc",
        "uriVariables": {
          "value": {
            "type": "string"
          }
        },
        "properties": {
          "status": {
            "forms": [
              {
                "href": "/base64/{value}",
                "contentType": "text/html"
              }
            ]
          },
          "status2": {
            "uriVariables": {
              "value": {
                "type": "integer"
              }
            },
            "forms": [
              {
                "href": "/base64/{value}"
              }
            ]
          }
        }
      }
      ''';

      final parsedTd = ThingDescription(thingDescriptionJson);

      final servient = Servient()..addClientFactory(HttpClientFactory());
      final wot = await servient.start();

      final uriVariables = {'value': 'SFRUUEJJTiBpcyBhd2Vzb21l'};
      final interactionOptions = InteractionOptions(uriVariables: uriVariables);

      final consumedThing = await wot.consume(parsedTd);
      final result =
          await consumedThing.readProperty('status', interactionOptions);
      final value = await result.value();
      expect(value, 'HTTPBIN is awesome');

      // status2 expects an integer instead of a String and throws an error if
      // the same value is provided as an input
      expect(
        consumedThing.readProperty('status2', interactionOptions),
        throwsA(const TypeMatcher<ValidationException>()),
      );

      await servient.shutdown();
      expect(servient.destroyConsumedThing(parsedTd.identifier), false);
    },
    skip: true, // TODO: Replace with test with local server
  );
}
