// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dart_wot/core.dart";
import "package:test/test.dart";

void main() {
  group("DartWotException should", () {
    test("be indicate the respective name in its toString() method", () {
      expect(
        DartWotException("test").toString(),
        "DartWotException: test",
      );

      expect(
        ValidationException("test").toString(),
        "ValidationException: test",
      );

      expect(
        ValidationException("test", ["test", "test"]).toString(),
        "ValidationException: test\n\nErrors:\n\ntest\ntest",
      );

      expect(
        DiscoveryException("test").toString(),
        "DiscoveryException: test",
      );
    });
  });
}
