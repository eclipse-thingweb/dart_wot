// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:convert";

import "package:curie/curie.dart";
import "package:dart_wot/core.dart";
import "package:dart_wot/src/core/definitions/context.dart";
import "package:dart_wot/src/core/definitions/extensions/json_parser.dart";
import "package:test/test.dart";

void main() {
  group("Definitions", () {
    setUp(() {
      // Additional setup goes here.
    });

    test("should not accept invalid Thing Descriptions", () {
      final illegalThingDescription = {"hello": "world"};

      expect(
        () => ThingDescription.fromJson(illegalThingDescription),
        throwsA(isA<FormatException>()),
      );
    });

    test("should accept valid Thing Descriptions", () {
      final validThingDescription = {
        "@context": "https://www.w3.org/2022/wot/td/v1.1",
        "title": "MyLampThing",
        "security": "nosec_sc",
        "securityDefinitions": {
          "nosec_sc": {"scheme": "nosec"},
        },
        "profile": ["https://example.org/test-profile"],
        "version": {"instance": "test"},
        "created": "1970-01-01",
        "forms": [
          {
            "href": "coaps://example.org",
            "op": "readallproperties",
          }
        ],
      };

      final thingDescription = ThingDescription.fromJson(validThingDescription);

      expect(thingDescription.title, "MyLampThing");
      expect(
        thingDescription.context,
        Context(
          [
            SingleContextEntry.fromString(
              "https://www.w3.org/2022/wot/td/v1.1",
            ),
          ],
        ),
      );
      expect(thingDescription.security, ["nosec_sc"]);
      expect(thingDescription.securityDefinitions["nosec_sc"]?.scheme, "nosec");
      expect(
        thingDescription.profile,
        [Uri.tryParse("https://example.org/test-profile")],
      );
      expect(
        thingDescription.version?.instance,
        "test",
      );
      expect(
        thingDescription.created,
        DateTime.tryParse("1970-01-01"),
      );
      final form = thingDescription.forms?[0];
      expect(
        form?.href,
        Uri.tryParse("coaps://example.org"),
      );
      expect(
        form?.op,
        [OperationType.readallproperties],
      );
    });

    test("Form", () {
      final uri = Uri.parse("https://example.org");
      final form = Form(
        uri,
      );

      expect(form.href, uri);

      final form2 = Form(
        uri,
        subprotocol: "test",
        scopes: const ["test"],
        response: const ExpectedResponse("application/json"),
        additionalFields: const <String, dynamic>{"test": "test"},
      );

      expect(form2.href, uri);
      expect(form2.contentType, "application/json");
      expect(form2.subprotocol, "test");
      expect(form2.scopes, ["test"]);
      expect(form2.response!.contentType, "application/json");
      expect(form2.additionalFields, {"test": "test"});

      final dynamic form3Json = jsonDecode(
        '''
      {
        "href": "https://example.org",
        "contentType": "application/json",
        "subprotocol": "test",
        "scopes": ["test1", "test2"],
        "response": {
          "contentType": "application/json"
        },
        "additionalResponses": {
          "contentType": "application/json",
          "success": false,
          "schema": "hallo"
        },
        "op": ["writeproperty", "readproperty"],
        "test": "test"
      }''',
      );

      final form3 = Form.fromJson(
        form3Json as Map<String, dynamic>,
        PrefixMapping(),
      );

      expect(form3.href, uri);
      expect(form3.contentType, "application/json");
      expect(form3.subprotocol, "test");
      expect(
        form3.op,
        [OperationType.writeproperty, OperationType.readproperty],
      );
      expect(form3.scopes, ["test1", "test2"]);
      expect(form3.response?.contentType, "application/json");
      expect(form3.additionalResponses, [
        const AdditionalExpectedResponse(
          "application/json",
          schema: "hallo",
          additionalFields: {},
        ),
      ]);
      expect(form3.additionalFields, {"test": "test"});

      final dynamic form4Json = jsonDecode(
        '''
      {
        "href": "https://example.org",
        "op": "writeproperty",
        "scopes": "test"
      }''',
      );

      final form4 = Form.fromJson(
        form4Json as Map<String, dynamic>,
        PrefixMapping(),
      );

      expect(form4.op, [OperationType.writeproperty]);
      expect(form4.scopes, ["test"]);

      final dynamic form5Json = jsonDecode(
        """
      {
      }""",
      );

      expect(
        () => Form.fromJson(
          form5Json as Map<String, dynamic>,
          PrefixMapping(),
        ),
        throwsException,
      );

      final dynamic form6Json = jsonDecode(
        '''
      {
        "href": "https://example.org",
        "contentType": "application/cbor",
        "additionalResponses": [
          {
            "schema": "hallo"
          }, {
            "contentType": "text/plain"
          }
        ],
        "op": ["writeproperty", "readproperty"],
        "test": "test"
      }''',
      );

      final form6 = Form.fromJson(
        form6Json as Map<String, dynamic>,
        PrefixMapping(),
      );

      final additionalResponses = form6.additionalResponses;

      final additionalResponse1 = additionalResponses![0];
      final additionalResponse2 = additionalResponses[1];

      expect(additionalResponse1.contentType, "application/cbor");
      expect(additionalResponse1.schema, "hallo");
      expect(additionalResponse1.success, false);

      expect(additionalResponse2.contentType, "text/plain");
      expect(additionalResponse2.schema, null);

      expect(
        () => <String, dynamic>{}.parseAffordanceForms(
          PrefixMapping(),
          {},
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test("should correctly parse actions", () {
      final validThingDescription = {
        "@context": "https://www.w3.org/2022/wot/td/v1.1",
        "title": "MyLampThing",
        "security": "nosec_sc",
        "securityDefinitions": {
          "nosec_sc": {"scheme": "nosec"},
        },
        "actions": {
          "action": {
            "safe": true,
            "idempotent": true,
            "synchronous": true,
            "forms": [
              {"href": "https://example.org"},
            ],
          },
          "actionWithDefaults": {
            "forms": [
              {"href": "https://example.org"},
            ],
          },
        },
      };

      final thingDescription = ThingDescription.fromJson(validThingDescription);

      final action = thingDescription.actions?["action"];
      expect(action?.safe, true);
      expect(action?.idempotent, true);
      expect(action?.synchronous, true);

      final actionWithDefaults =
          thingDescription.actions?["actionWithDefaults"];
      expect(actionWithDefaults?.safe, false);
      expect(actionWithDefaults?.idempotent, false);
      expect(actionWithDefaults?.synchronous, null);
    });

    test("should correctly parse properties", () {
      final validThingDescription = {
        "@context": "https://www.w3.org/2022/wot/td/v1.1",
        "title": "MyLampThing",
        "security": "nosec_sc",
        "securityDefinitions": {
          "nosec_sc": {"scheme": "nosec"},
          "auto_sc": {"scheme": "auto"},
        },
        "properties": {
          "property": {
            "@type": "test",
            "title": "Test",
            "titles": {"de": "German Test", "en": "English Test"},
            "description": "This is a Test",
            "descriptions": {
              "es": "Esto es una prueba",
              "en": "This is a Test",
            },
            "writeOnly": true,
            "readOnly": true,
            "observable": true,
            "enum": ["On", "Off", 3],
            "constant": "On",
            "default": "On",
            "unit": "C",
            "contentEncoding": "test",
            "contentMediaType": "test",
            "type": "string",
            "forms": [
              {"href": "https://example.org"},
            ],
            "format": "test",
            "pattern": "test",
            "items": [
              {"type": "integer"},
            ],
            "minLength": 2,
            "maxLength": 5,
            "minItems": 2,
            "maxItems": 5,
            "exclusiveMinimum": 3,
            "exclusiveMaximum": 3,
            "multipleOf": 1,
            "minimum": 3,
            "maximum": 3,
          },
          "propertyWithDefaults": {
            "forms": [
              {"href": "https://example.org"},
            ],
          },
          "objectSchemeProperty": {
            "type": "object",
            "properties": {
              "test": {"type": "string"},
            },
            "required": ["test"],
            "forms": [
              {
                "href": "https://example.org",
                "security": "auto_sc",
              }
            ],
          },
          "propertyWithOneOf": {
            "oneOf": [
              {"type": "string"},
              {"type": "integer"},
            ],
            "forms": [
              {"href": "https://example.org"},
            ],
          },
        },
      };

      final thingDescription = ThingDescription.fromJson(validThingDescription);

      expect(thingDescription.security[0], "nosec_sc");
      final noSecurityScheme = thingDescription.securityDefinitions["nosec_sc"];
      expect(noSecurityScheme, isA<NoSecurityScheme>());
      expect(noSecurityScheme?.scheme, "nosec");

      final property = thingDescription.properties?["property"];
      expect(property?.atType, ["test"]);
      expect(property?.title, "Test");
      expect(property?.description, "This is a Test");
      expect(property?.descriptions?["es"], "Esto es una prueba");
      expect(property?.descriptions?["en"], "This is a Test");
      expect(property?.writeOnly, true);
      expect(property?.readOnly, true);
      expect(property?.observable, true);
      expect(property?.enumeration, ["On", "Off", 3]);
      expect(property?.constant, "On");
      expect(property?.defaultValue, "On");
      expect(property?.format, "test");
      expect(property?.pattern, "test");
      expect(property?.contentEncoding, "test");
      expect(property?.contentMediaType, "test");
      expect(property?.unit, "C");
      expect(property?.items?[0].type, "integer");
      expect(property?.minLength, 2);
      expect(property?.maxLength, 5);
      expect(property?.minItems, 2);
      expect(property?.maxItems, 5);
      expect(property?.exclusiveMinimum, 3);
      expect(property?.exclusiveMaximum, 3);
      expect(property?.minimum, 3);
      expect(property?.maximum, 3);
      expect(property?.multipleOf, 1);

      final propertyWithDefaults =
          thingDescription.properties?["propertyWithDefaults"];
      expect(propertyWithDefaults?.writeOnly, false);
      expect(propertyWithDefaults?.readOnly, false);
      expect(propertyWithDefaults?.observable, false);

      final objectSchemeProperty =
          thingDescription.properties?["objectSchemeProperty"];
      expect(objectSchemeProperty?.required, ["test"]);
      expect(objectSchemeProperty?.type, "object");

      expect(objectSchemeProperty?.forms[0].security, ["auto_sc"]);
      // final autoSecurityScheme =
      // objectSchemeProperty?.forms[0].securityDefinitions[0];
      // expect(autoSecurityScheme, isA<AutoSecurityScheme>());
      // expect(autoSecurityScheme?.scheme, "auto");

      final testSchema = objectSchemeProperty?.properties?["test"];
      expect(testSchema, isA<DataSchema>());
      expect(testSchema?.type, "string");
      final propertyWithOneOf =
          thingDescription.properties?["propertyWithOneOf"];
      final stringSchema = propertyWithOneOf?.oneOf?[0];
      final integerSchema = propertyWithOneOf?.oneOf?[1];

      expect(stringSchema, isA<DataSchema>());
      expect(stringSchema?.type, "string");
      expect(integerSchema, isA<DataSchema>());
      expect(integerSchema?.type, "integer");
    });
  });

  test("Should correctly parse Additional SecuritySchemes", () {
    final rawThingDescription = {
      "@context": [
        "https://www.w3.org/2022/wot/td/v1.1",
        {
          "ace": "http://www.example.org/ace-security#",
          "saref": "https://w3id.org/saref#",
        }
      ],
      "id": "urn:uuid:5edfed77-fc4e-46d4-a550-ef7f07592fbd",
      "@type": ["saref:LightSwitch"],
      "title": "NAMIB WoT Thing",
      "base": "coap://192.168.71.200",
      "properties": {
        "status": {
          "@type": ["saref:OnOffState"],
          "title": "Lamp status",
          "description": "The status of the lamp",
          "forms": [
            {
              "op": ["readproperty"],
              "href": "led/status",
              "contentType": "application/json",
            }
          ],
          "enum": ["On", "Off"],
          "readOnly": true,
          "writeOnly": false,
          "type": "string",
        },
      },
      "actions": {
        "toggle": {
          "@type": ["saref:ToggleCommand"],
          "title": "Toggle lamp",
          "description": "Toggle the status of the lamp",
          "forms": [
            {
              "op": ["invokeaction"],
              "href": "led/toggle",
              "contentType": "application/json",
            }
          ],
          "output": {"readOnly": false, "writeOnly": false, "type": "string"},
          "safe": false,
          "idempotent": false,
        },
      },
      "security": ["ace_sc"],
      "securityDefinitions": {
        "ace_sc": {
          "scheme": "ace:ACESecurityScheme",
          "ace:as": "coaps://192.168.42.205:7744/authorize",
          "ace:audience": "NAMIB_Demonstrator",
          "ace:scopes": ["led/status", "led/toggle", "temperature/value"],
        },
      },
    };

    final thingDescription = ThingDescription.fromJson(rawThingDescription);
    expect(
      thingDescription.securityDefinitions["ace_sc"]?.scheme,
      "ace:ACESecurityScheme",
    );
  });

  test("Should only parse allowed Operation Types", () {
    expect(
      OperationType.fromString("invokeaction"),
      OperationType.invokeaction,
    );

    expect(
      () => OperationType.fromString("test"),
      throwsA(isA<FormatException>()),
    );
  });

  test("Should correctly parse ExpectedResponse", () {
    const firstResponse = ExpectedResponse(
      "application/json",
      additionalFields: {"test": "test"},
    );

    expect(firstResponse.additionalFields?["test"], "test");

    final expectedResponseJson = {
      "contentType": "application/json",
      "test": "test",
    };

    final secondResponse =
        ExpectedResponse.fromJson(expectedResponseJson, PrefixMapping());

    expect(secondResponse, isA<ExpectedResponse>());
    expect(secondResponse.additionalFields?["test"], "test");
  });

  test("Should reject invalid @context entries", () {
    final invalidThingDescription1 = {
      "@context": 5,
      "title": "Test",
      "security": "nosec_sc",
      "securityDefinitions": {
        "nosec_sc": {"scheme": "nosec"},
      },
    };

    expect(
      () => ThingDescription.fromJson(
        invalidThingDescription1,
        validate: false,
      ),
      throwsA(isA<FormatException>()),
    );

    final invalidThingDescription2 = {
      "@context": ["https://www.w3.org/2022/wot/td/v1.1", 5],
      "title": "Test",
      "security": "nosec_sc",
      "securityDefinitions": {
        "nosec_sc": {"scheme": "nosec"},
      },
    };

    expect(
      () => ThingDescription.fromJson(invalidThingDescription2),
      throwsA(isA<FormatException>()),
    );
  });

  test("Should reject invalid @context entries", () {
    // TODO(JKRhb): Double-check if this the correct behavior.
    final invalidThingDescription1 = {
      "@context": [
        "https://www.w3.org/2022/wot/td/v1.1",
        {"invalid": 1},
      ],
      "title": "NAMIB WoT Thing",
      "security": ["nosec_sc"],
      "securityDefinitions": {
        "nosec_sc": {
          "scheme": "nosec",
        },
      },
    };

    expect(
      () => ThingDescription.fromJson(invalidThingDescription1),
      throwsA(isA<FormatException>()),
    );
  });
}
