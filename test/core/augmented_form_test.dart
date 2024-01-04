// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dart_wot/core.dart";
import "package:test/test.dart";

void main() {
  group("AugmentedForm should", () {
    test("be able to be instantiated", () {
      const id = "urn:foobar";
      const href = "http://example.org";
      const href2 = "coap://example.org";
      final thingDescription = ThingDescription.fromJson(
        const {
          "@context": "https://www.w3.org/2022/wot/td/v1.1",
          "title": "Test TD",
          "id": id,
          "properties": {
            "test": {
              "forms": [
                {
                  "href": href,
                  "contentCoding": "gzip",
                  "scopes": ["hi"],
                  "subprotocol": "Hyper Text Coffee Pot Control Protocol",
                  "additionalResponses": [
                    {
                      "contentType": "application/json",
                    },
                  ],
                }
              ],
            },
            "test2": {
              "forms": [
                {
                  "href": "/test",
                },
              ],
            },
          },
          "base": href2,
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

      expect(augmentedForm.href, Uri.parse(href));
      expect(augmentedForm.security, ["nosec_sc"]);
      expect(augmentedForm.securityDefinitions.first, isA<NoSecurityScheme>());
      expect(augmentedForm.tdIdentifier, id);
      expect(
        augmentedForm.additionalResponses?.first.contentType,
        "application/json",
      );
      expect(augmentedForm.contentCoding, "gzip");
      expect(augmentedForm.contentType, "application/json");
      expect(augmentedForm.scopes, ["hi"]);
      expect(
        augmentedForm.subprotocol,
        "Hyper Text Coffee Pot Control Protocol",
      );

      final affordance2 = thingDescription.properties?["test2"];

      final augmentedForm2 = AugmentedForm(
        affordance2!.forms[0],
        affordance2,
        thingDescription,
        const {},
      );
      expect(augmentedForm2.href, Uri.parse("$href2/test"));
    });

    test("handle URI variables", () {
      final thingDescription = ThingDescription.fromJson(
        const {
          "@context": "https://www.w3.org/2022/wot/td/v1.1",
          "title": "Test TD",
          "properties": {
            "test": {
              "uriVariables": {
                "lat": {
                  "type": "number",
                  "minimum": 0,
                  "maximum": 90,
                  "description":
                      "Latitude for the desired location in the world",
                },
              },
              "forms": [
                {
                  "href": "http://example.org/weather/{?lat,long}",
                },
                {
                  "href": "http://example.org/weather/{?foo}",
                },
                {
                  "href": "http://example.org/weather",
                },
              ],
            },
          },
          "uriVariables": {
            "long": {
              "type": "number",
              "minimum": -180,
              "maximum": 180,
              "description": "Longitude for the desired location in the world",
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

      final augmentedForm1 = AugmentedForm(
        affordance!.forms.first,
        affordance,
        thingDescription,
        const {
          "lat": 5,
          "long": 10,
        },
      );

      expect(
        augmentedForm1.resolvedHref,
        Uri.parse("http://example.org/weather/?lat=5&long=10"),
      );

      expect(
        augmentedForm1.resolvedHref != augmentedForm1.href,
        isTrue,
      );

      final augmentedForm2 = AugmentedForm(
        affordance.forms.first,
        affordance,
        thingDescription,
        const {
          "lat": 5,
        },
      );

      expect(
        () => augmentedForm2.resolvedHref,
        throwsA(isA<UriVariableException>()),
      );

      final augmentedForm3 = AugmentedForm(
        affordance.forms.first,
        affordance,
        thingDescription,
        const {
          "long": 10,
        },
      );

      expect(
        () => augmentedForm3.resolvedHref,
        throwsA(
          predicate(
            (exception) =>
                exception is UriVariableException &&
                exception.toString() ==
                    "UriVariableException: The following URI template "
                        "variables defined at the TD level are not covered by "
                        "the values provided by the user: lat. Values for the "
                        "following variables were received: long.",
          ),
        ),
      );

      final augmentedForm4 = AugmentedForm(
        affordance.forms.first,
        affordance,
        thingDescription,
        const {
          "lat": "hi",
          "long": 10,
        },
      );

      expect(
        () => augmentedForm4.resolvedHref,
        throwsA(isA<ValidationException>()),
      );

      final augmentedForm5 = AugmentedForm(
        affordance.forms[1],
        affordance,
        thingDescription,
        const {
          "lat": "hi",
          "long": 10,
        },
      );

      expect(
        () => augmentedForm5.resolvedHref,
        throwsA(isA<ValidationException>()),
      );

      final augmentedForm6 = AugmentedForm(
        affordance.forms[2],
        affordance,
        thingDescription,
        const {},
      );

      expect(
        augmentedForm6.href,
        augmentedForm6.resolvedHref,
      );
    });
  });
}
