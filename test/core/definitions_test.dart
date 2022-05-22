// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:convert';

import 'package:curie/curie.dart';
import 'package:dart_wot/src/definitions/expected_response.dart';
import 'package:dart_wot/src/definitions/form.dart';
import 'package:test/test.dart';

void main() {
  group('Definitions', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Form', () {
      final prefixMapping = PrefixMapping(
          defaultPrefixValue: "https://www.w3.org/2019/wot/td/v1");
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

      final dynamic form3Json = jsonDecode("""
      {
        "href": "https://example.org",
        "contentType": "application/json",
        "subprotocol": "test",
        "scopes": ["test1", "test2"],
        "response": {
          "contentType": "application/json"
        },
        "security": ["test1", "test2"],
        "op": ["writeproperty", "readproperty"],
        "test": "test"
      }""");

      final form3 =
          Form.fromJson(form3Json as Map<String, dynamic>, prefixMapping);

      expect(form3.href, "https://example.org");
      expect(form3.contentType, "application/json");
      expect(form3.subprotocol, "test");
      expect(form3.security, ["test1", "test2"]);
      expect(form3.op, ["writeproperty", "readproperty"]);
      expect(form3.scopes, ["test1", "test2"]);
      expect(form3.response?.contentType, "application/json");
      expect(form3.additionalFields, {"test": "test"});

      final dynamic form4Json = jsonDecode("""
      {
        "href": "https://example.org",
        "security": "test",
        "op": "writeproperty",
        "scopes": "test"
      }""");

      final form4 =
          Form.fromJson(form4Json as Map<String, dynamic>, prefixMapping);

      expect(form4.security, ["test"]);
      expect(form4.op, ["writeproperty"]);
      expect(form4.scopes, ["test"]);

      final dynamic form5Json = jsonDecode("""
      {
      }""");

      expect(
          () => Form.fromJson(form5Json as Map<String, dynamic>, prefixMapping),
          throwsArgumentError);
    });
  });
}