// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/src/definitions/expected_response.dart';
import 'package:dart_wot/src/definitions/form.dart';
import 'package:test/test.dart';

void main() {
  group('Definitions', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Form', () {
      final form = Form("https://example.org");

      expect(form.href, "https://example.org");

      final form2 = Form("https://example.org",
          contentType: "application/json",
          subprotocol: "test",
          security: ["test"],
          scopes: ["test"],
          response: ExpectedResponse("application/json"),
          additionalFields: <String, dynamic>{"test": "test"});

      expect(form2.href, "https://example.org");
      expect(form2.contentType, "application/json");
      expect(form2.subprotocol, "test");
      expect(form2.security, ["test"]);
      expect(form2.scopes, ["test"]);
      expect(form2.response!.contentType, "application/json");
      expect(form2.additionalFields, {"test": "test"});
    });
  });
}
