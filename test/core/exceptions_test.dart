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
        const DartWotException("test").toString(),
        "DartWotException: test",
      );

      expect(
        const DiscoveryException("test").toString(),
        "DiscoveryException: test",
      );

      expect(
        const NotReadableException("test").toString(),
        "NotReadableException: test",
      );
    });
  });
}
