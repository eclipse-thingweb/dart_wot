// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:convert';

import 'package:dart_wot/dart_wot.dart';
import 'package:dart_wot/src/definitions/additional_expected_response.dart';
import 'package:dart_wot/src/definitions/context_entry.dart';
import 'package:dart_wot/src/definitions/expected_response.dart';
import 'package:dart_wot/src/definitions/interaction_affordances/property.dart';
import 'package:dart_wot/src/definitions/operation_type.dart';
import 'package:dart_wot/src/definitions/validation/thing_description_schema.dart';
import 'package:test/test.dart';

void main() {
  group('Definitions', () {
    setUp(() {
      // Additional setup goes here.
    });

    test("should not accept invalid Thing Descriptions", () {
      final illegalThingDescription = {"hello": "world"};

      expect(() => ThingDescription.fromJson(illegalThingDescription),
          throwsA(isA<ThingDescriptionValidationException>()));
    });

    test("should accept valid Thing Descriptions", () {
      final validThingDescription = {
        "@context": "https://www.w3.org/2022/wot/td/v1.1",
        "title": "MyLampThing",
        "security": "nosec_sc",
        "securityDefinitions": {
          "nosec_sc": {"scheme": "nosec"}
        }
      };

      final thingDescription = ThingDescription.fromJson(validThingDescription);

      expect(thingDescription.title, "MyLampThing");
      expect(thingDescription.context,
          [ContextEntry("https://www.w3.org/2022/wot/td/v1.1", null)]);
      expect(thingDescription.security, ["nosec_sc"]);
      expect(thingDescription.securityDefinitions["nosec_sc"]?.scheme, "nosec");
    });

    test('Form', () {
      final thingDescription = ThingDescription(null);
      final interactionAffordance = Property([], thingDescription);

      final uri = Uri.parse("https://example.org");
      final form = Form(uri, interactionAffordance);

      expect(form.href, uri);

      final form2 = Form(uri, interactionAffordance,
          contentType: "application/json",
          subprotocol: "test",
          scopes: ["test"],
          response: ExpectedResponse("application/json"),
          additionalFields: <String, dynamic>{"test": "test"});

      expect(form2.href, uri);
      expect(form2.contentType, "application/json");
      expect(form2.subprotocol, "test");
      expect(form2.scopes, ["test"]);
      expect(form2.response!.contentType, "application/json");
      expect(form2.additionalFields, {"test": "test"});

      final dynamic form3Json = jsonDecode("""
      {
        "href": "https://example.org",
        "contentType": "application/json",
        "subprotocol": "test",
        "scopes": ["test1", "test2"],
        "response": {
          "contentType": "application/json"
        },
        "additionalResponses": {
          "success": false,
          "schema": "hallo"
        },
        "op": ["writeproperty", "readproperty"],
        "test": "test"
      }""");

      final form3 = Form.fromJson(
          form3Json as Map<String, dynamic>, interactionAffordance);

      expect(form3.href, uri);
      expect(form3.contentType, "application/json");
      expect(form3.subprotocol, "test");
      expect(
          form3.op, [OperationType.writeproperty, OperationType.readproperty]);
      expect(form3.scopes, ["test1", "test2"]);
      expect(form3.response?.contentType, "application/json");
      expect(form3.additionalResponses, [
        AdditionalExpectedResponse("application/json",
            success: false, schema: "hallo")
      ]);
      expect(form3.additionalFields, {"test": "test"});

      final dynamic form4Json = jsonDecode("""
      {
        "href": "https://example.org",
        "op": "writeproperty",
        "scopes": "test"
      }""");

      final form4 = Form.fromJson(
          form4Json as Map<String, dynamic>, interactionAffordance);

      expect(form4.op, [OperationType.writeproperty]);
      expect(form4.scopes, ["test"]);

      final dynamic form5Json = jsonDecode("""
      {
      }""");

      expect(
          () => Form.fromJson(
              form5Json as Map<String, dynamic>, interactionAffordance),
          throwsException);

      final dynamic form6Json = jsonDecode("""
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
      }""");

      final form6 = Form.fromJson(
          form6Json as Map<String, dynamic>, interactionAffordance);

      final additionalResponses = form6.additionalResponses;

      final additionalResponse1 = additionalResponses![0];
      final additionalResponse2 = additionalResponses[1];

      expect(additionalResponse1.contentType, "application/cbor");
      expect(additionalResponse1.schema, "hallo");
      expect(additionalResponse1.success, false);

      expect(additionalResponse2.contentType, "text/plain");
      expect(additionalResponse2.schema, null);
    });

    test("should correctly parse actions", () {
      final validThingDescription = {
        "@context": "https://www.w3.org/2022/wot/td/v1.1",
        "title": "MyLampThing",
        "security": "nosec_sc",
        "securityDefinitions": {
          "nosec_sc": {"scheme": "nosec"}
        },
        "actions": {
          "action": {
            "safe": true,
            "idempotent": true,
            "synchronous": true,
            "forms": [
              {"href": "https://example.org"}
            ]
          },
          "actionWithDefaults": {
            "forms": [
              {"href": "https://example.org"}
            ]
          }
        }
      };

      final thingDescription = ThingDescription.fromJson(validThingDescription);

      final action = thingDescription.actions["action"];
      expect(action?.safe, true);
      expect(action?.idempotent, true);
      expect(action?.synchronous, true);

      final actionWithDefaults = thingDescription.actions["actionWithDefaults"];
      expect(actionWithDefaults?.safe, false);
      expect(actionWithDefaults?.idempotent, false);
      expect(actionWithDefaults?.synchronous, null);
    });
  });
}
