// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dart_wot/core.dart";
import "package:dart_wot/src/core/definitions/context.dart";
import "package:dart_wot/src/core/definitions/extensions/json_parser.dart";
import "package:test/test.dart";

void main() {
  group("Thing Description @context should", () {
    test("not allow for an invalid first entry", () {
      final illegalSingleContextEntry =
          SingleContextEntry.fromString("https://example.com");

      expect(
        () => Context([illegalSingleContextEntry]),
        throwsA(isA<ValidationException>()),
      );
    });

    test("be supported when including both the TD 1.0 and 1.1 URL", () {
      const tdVersion11ContextUrl = "https://www.w3.org/2022/wot/td/v1.1";

      final tdVersion10ContextEntry =
          SingleContextEntry.fromString("https://www.w3.org/2019/wot/td/v1");

      final tdVersion11ContextEntry =
          SingleContextEntry.fromString(tdVersion11ContextUrl);

      expect(
        Context([tdVersion10ContextEntry, tdVersion11ContextEntry])
            .prefixMapping
            .defaultPrefixValue,
        tdVersion11ContextUrl,
      );
    });

    test("support the inclusion of non-URI map entries", () {
      final contextJson = {
        "@context": [
          "https://www.w3.org/2022/wot/td/v1.1",
          {
            "@language": "en",
          }
        ],
      };

      final parsedContext = contextJson.parseContext({});

      expect(
        Context([
          SingleContextEntry.fromString("https://www.w3.org/2022/wot/td/v1.1"),
          const StringMapContextEntry("@language", "en"),
        ]),
        parsedContext,
      );
    });

    test("correctly override the hashCode getter", () {
      final contextEntry1 =
          SingleContextEntry.fromString("https://www.w3.org/2022/wot/td/v1.1");
      final contextEntry2 =
          SingleContextEntry.fromString("https://www.w3.org/2022/wot/td/v1.1");

      final context1 = Context([contextEntry1]);
      final context2 = Context([contextEntry2]);

      expect(context1.hashCode, context2.hashCode);
    });
  });

  group("SingleContextEntry should", () {
    test("only be valid when created from a valid URI", () {
      expect(
        () => SingleContextEntry.fromString("::foobar::"),
        throwsA(isA<ValidationException>()),
      );
    });

    test("correctly override the hashCode getter", () {
      const string1 = "foobar";
      const string2 = "foobar";

      final singleContextValue1 = SingleContextEntry.fromString(string1);
      final singleContextValue2 = SingleContextEntry.fromString(string2);

      expect(string1.hashCode, string2.hashCode);

      expect(singleContextValue1.hashCode, singleContextValue2.hashCode);
    });
  });

  group("UriMapContextEntry should", () {
    test("correctly override the == operator", () {
      final uriMapContextValue1 = UriMapContextEntry("foo", Uri.parse("bar"));
      final uriMapContextValue2 = UriMapContextEntry("foo", Uri.parse("bar"));

      expect(
        uriMapContextValue1 == uriMapContextValue2,
        isTrue,
      );

      final singleContextValue = SingleContextEntry.fromString("foo");

      expect(
        // ignore: unrelated_type_equality_checks
        uriMapContextValue1 == singleContextValue,
        isFalse,
      );
    });

    test("correctly override the hashCode getter", () {
      const key1 = "foo";
      const key2 = "foo";

      final value1 = Uri.parse("bar");
      final value2 = Uri.parse("bar");

      final uriMapContextValue1 = UriMapContextEntry(key1, value1);
      final uriMapContextValue2 = UriMapContextEntry(key2, value2);

      expect(key1.hashCode, key2.hashCode);
      expect(value1.hashCode, value2.hashCode);

      expect(uriMapContextValue1.hashCode, uriMapContextValue2.hashCode);
    });
  });
}
