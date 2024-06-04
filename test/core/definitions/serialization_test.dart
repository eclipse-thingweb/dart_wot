// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause
import "package:curie/curie.dart";
import "package:dart_wot/core.dart";
import "package:dart_wot/src/core/definitions/version_info.dart";
import "package:test/test.dart";

void main() {
  group("Should serialize and deserialize", () {
    test("ThingDescriptions", () async {
      final thingDescriptionJson = {
        "@context": ["https://www.w3.org/2022/wot/td/v1.1"],
        "@type": ["foobar"],
        "title": "Test Thing",
        "titles": {
          "en": "Test Thing",
        },
        "description": "Test Thing",
        "descriptions": {
          "en": "Test Thing",
        },
        "version": {
          "instance": "1.0.0",
        },
        // TODO: Should fields like these be able to be "roundtripped"?
        //       I.e., getting the same result back that was put in?
        "created": "2024-05-25T00:00:00.000",
        "modified": "2024-05-25T00:00:00.000",
        "support": "https://example.org",
        "base": "https://example.org",
        "id": "urn:uuid:5edfed77-fc4e-46d4-a550-ef7f07592fbd",
        "forms": [
          {
            "href": "https://example.org",
            "op": [
              "readmultipleproperties",
            ],
            // TODO: Should defaults actually be set?
            "contentType": "application/json",
          },
        ],
        "properties": {},
        "actions": {},
        "events": {},
        "links": [],
        "schemaDefinitions": {},
        "uriVariables": {},
        "profile": ["https://example.org"],
        "security": ["nosec_sc"],
        "securityDefinitions": {
          "nosec_sc": {
            "scheme": "nosec",
          },
        },
      };

      final thingDescription = thingDescriptionJson.toThingDescription();

      expect(
        thingDescriptionJson,
        thingDescription.toJson(),
      );
    });

    test("VersionInfo", () async {
      final versionInfoJson = {
        "instance": "1.0.0",
        "model": "1.0.0",
      };

      final versionInfo =
          VersionInfo.fromJson(versionInfoJson, PrefixMapping());

      expect(
        versionInfoJson,
        versionInfo.toJson(),
      );
    });

    test("Links", () async {
      final linkJson = {
        "href": "https://example.org",
        "anchor": "https://example.org",
        "type": "",
        "rel": "me",
        "sizes": "42x42",
        "hreflang": ["en"],
      };

      final link = Link.fromJson(linkJson, PrefixMapping());

      expect(
        linkJson,
        link.toJson(),
      );
    });

    test("Forms", () async {
      final formJson = {
        "href": "https://example.org",
        "subprotocol": "foobar",
        "contentCoding": "test",
        "contentType": "application/json",
        "security": ["test"],
        "response": {
          "contentType": "application/json",
        },
        "additionalResponses": [],
        "scopes": ["foo", "bar"],
      };

      final form = Form.fromJson(formJson, PrefixMapping());

      expect(
        formJson,
        form.toJson(),
      );
    });

    test("AugmentedForms", () async {
      final formJson = {
        "href": "https://example.org",
        "contentType": "application/json",
      };

      final thingDescription = {
        "@context": ["https://www.w3.org/2022/wot/td/v1.1"],
        "title": "Test Thing",
        "properties": {
          "test": {
            "forms": [
              formJson,
            ],
          },
        },
        "security": ["nosec_sc"],
        "securityDefinitions": {
          "nosec_sc": {
            "scheme": "nosec",
          },
        },
      }.toThingDescription();

      final property = thingDescription.properties!["test"];
      final form = property!.forms[0];

      final augmentedForm =
          AugmentedForm(form, property, thingDescription, null);

      expect(
        formJson,
        augmentedForm.toJson(),
      );
    });

    test("AdditionalExpectedResponses", () async {
      final additionalExpectedResponseJson = {
        "success": true,
        "contentType": "application/cbor",
        "schema": "foobar",
      };

      final additionalExpectedResponse = AdditionalExpectedResponse.fromJson(
        additionalExpectedResponseJson,
        // TODO: Document this parameter
        "application/json",
        PrefixMapping(),
      );

      expect(
        additionalExpectedResponseJson,
        additionalExpectedResponse.toJson(),
      );
    });

    test("Actions", () async {
      final actionJson = {
        "input": {},
        "output": {},
        "idempotent": true,
        "safe": true,
        "synchronous": true,
        "forms": [
          {
            "href": "https://example.org",
            "contentType": "application/json",
          }
        ],
      };

      final action = Action.fromJson(
        actionJson,
        PrefixMapping(),
      );

      expect(
        actionJson,
        action.toJson(),
      );
    });

    test("DataSchemas", () async {
      final dataSchemaJson = {
        "items": [
          {
            "type": "string",
          }
        ],
        "properties": {
          "baz": {
            "type": "string",
          },
        },
      };

      final dataSchema = DataSchema.fromJson(
        dataSchemaJson,
        PrefixMapping(),
      );

      expect(
        dataSchemaJson,
        dataSchema.toJson(),
      );
    });

    test("OAuth2SecurityScheme", () async {
      final oAuth2SecuritySchemeJson = {
        "scheme": "oauth2",
        "authorization": "https://example.org",
        "token": "https://example.org",
        "refresh": "https://example.org",
        "scopes": ["foo", "bar"],
        "flow": "code",
      };

      final parsedFields = {"scheme"};

      final oAuth2SecurityScheme = OAuth2SecurityScheme.fromJson(
        oAuth2SecuritySchemeJson,
        PrefixMapping(),
        parsedFields,
      );

      expect(
        oAuth2SecuritySchemeJson,
        oAuth2SecurityScheme.toJson(),
      );
    });

    test("BearerSecurityScheme", () async {
      final bearerSecuritySchemeJson = {
        "scheme": "bearer",
        "authorization": "https://example.org",
        "name": "foobar",
        "alg": "ES256",
        "format": "jwt",
        "in": "header",
      };

      final parsedFields = {"scheme"};

      final bearerSecurityScheme = BearerSecurityScheme.fromJson(
        bearerSecuritySchemeJson,
        PrefixMapping(),
        parsedFields,
      );

      expect(
        bearerSecuritySchemeJson,
        bearerSecurityScheme.toJson(),
      );
    });

    test("DigestSecurityScheme", () async {
      final digestSecuritySchemeJson = {
        "scheme": "digest",
        "name": "foobar",
        "in": "header",
        "qop": "auth",
      };

      final parsedFields = {"scheme"};

      final digestSecurityScheme = DigestSecurityScheme.fromJson(
        digestSecuritySchemeJson,
        PrefixMapping(),
        parsedFields,
      );

      expect(
        digestSecuritySchemeJson,
        digestSecurityScheme.toJson(),
      );
    });

    test("BasicSecurityScheme", () async {
      final basicSecuritySchemeJson = {
        "scheme": "basic",
        "name": "foobar",
        "in": "header",
      };

      final parsedFields = {"scheme"};

      final basicSecurityScheme = BasicSecurityScheme.fromJson(
        basicSecuritySchemeJson,
        PrefixMapping(),
        parsedFields,
      );

      expect(
        basicSecuritySchemeJson,
        basicSecurityScheme.toJson(),
      );
    });

    test("ApiKeySecurityScheme", () async {
      final apiKeySecuritySchemeJson = {
        "scheme": "apikey",
        "name": "foobar",
        "in": "query",
      };

      final parsedFields = {"scheme"};

      final apiKeySecurityScheme = ApiKeySecurityScheme.fromJson(
        apiKeySecuritySchemeJson,
        PrefixMapping(),
        parsedFields,
      );

      expect(
        apiKeySecuritySchemeJson,
        apiKeySecurityScheme.toJson(),
      );
    });

    test("PskSecurityScheme", () async {
      final pskSecuritySchemeJson = {
        "scheme": "psk",
        "identity": "foobar",
        "proxy": "https://example.org",
        "description": "Hi. This is a test",
        "description2": {
          "en": "Hi. This is a test",
        },
        "@type": ["bar", "baz"],
      };

      final parsedFields = {"scheme"};

      final pskSecurityScheme = PskSecurityScheme.fromJson(
        pskSecuritySchemeJson,
        PrefixMapping(),
        parsedFields,
      );

      expect(
        pskSecuritySchemeJson,
        pskSecurityScheme.toJson(),
      );
    });

    test("ComboSecurityScheme", () async {
      for (final comboVariantKey in ["allOf", "oneOf"]) {
        final comboSecuritySchemeJson = {
          "scheme": "combo",
          comboVariantKey: ["foo", "bar"],
        };

        final parsedFields = {"scheme"};

        final comboSecurityScheme = ComboSecurityScheme.fromJson(
          comboSecuritySchemeJson,
          PrefixMapping(),
          parsedFields,
        );

        expect(
          comboSecuritySchemeJson,
          comboSecurityScheme.toJson(),
        );
      }
    });

    test("AceSecurityScheme", () async {
      final aceSecuritySchemeJson = {
        "scheme": "ace:ACESecurityScheme",
        "ace:as": "https://example.org",
        "ace:audience": "foobar",
        "ace:scopes": ["foo", "bar"],
        "ace:cnonce": true,
      };

      final parsedFields = {"scheme"};

      final aceSecurityScheme = AceSecurityScheme.fromJson(
        aceSecuritySchemeJson,
        PrefixMapping(),
        parsedFields,
      );

      expect(
        aceSecuritySchemeJson,
        aceSecurityScheme.toJson(),
      );
    });
  });
}
