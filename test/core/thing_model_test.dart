// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dart_wot/core.dart";
import "package:test/test.dart";

void main() {
  group("ThingModel should", () {
    test("be able to be instantiated", () {
      final json = {
        "title": "Test TM",
      };
      final thingModel = ThingModel.fromJson(json);

      expect(thingModel.title, "Test TM");
      expect(thingModel.id, isNull);
    });
  });
}
