// Copyright 2023 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:coap/coap.dart";
import "package:dart_wot/core.dart";
import "package:dart_wot/src/binding_coap/coap_definitions.dart";
import "package:dart_wot/src/binding_coap/coap_extensions.dart";
import "package:test/test.dart";

void main() {
  group("CoAP definitions should", () {
    test("deserialize CoAP Forms", () async {
      const thingDescriptionJson = {
        "@context": [
          "https://www.w3.org/2022/wot/td/v1.1",
          {"cov": "http://www.example.org/coap-binding#"},
        ],
        "title": "Test Thing",
        "properties": {
          "status": {
            "forms": [
              {
                "href": "coap://example.org",
                "cov:method": "iPATCH",
                "contentType": "application/cbor",
                "cov:contentFormat": 60,
                "cov:accept": 60,
                "cov:blockwise": {
                  "cov:block1Size": 32,
                  "cov:block2Size": 64,
                },
                "response": {
                  "contentType": "application/cbor",
                  "cov:contentFormat": 60,
                },
              },
              {
                "href": "coap://example.org",
                "cov:blockwise": {
                  "cov:block1Size": 5000,
                  "cov:block2Size": 4096,
                },
              },
            ],
          },
        },
        "securityDefinitions": {
          "nosec_sc": {"scheme": "nosec"},
        },
        "security": ["nosec_sc"],
      };

      final thingDescription = ThingDescription.fromJson(thingDescriptionJson);
      final property = thingDescription.properties?["status"];
      final form = AugmentedForm(
        property!.forms.first,
        property,
        thingDescription,
        const {},
      );

      expect(form.href, Uri.parse("coap://example.org"));
      expect(form.method, CoapRequestMethod.ipatch);
      expect(form.contentFormat, CoapMediaType.applicationCbor);
      expect(form.accept, CoapMediaType.applicationCbor);
      expect(form.block1Size, BlockSize.blockSize32);
      expect(form.block2Size, BlockSize.blockSize64);
      expect(form.response?.contentFormat, CoapMediaType.applicationCbor);

      // TODO(JKRhb): Validation should happen earlier

      final invalidForm = AugmentedForm(
        property.forms[1],
        property,
        thingDescription,
        const {},
      );
      expect(
        () => invalidForm.block1Size,
        throwsA(isA<FormatException>()),
      );
      expect(
        () => invalidForm.block2Size,
        throwsA(isA<FormatException>()),
      );
    });
  });
}
