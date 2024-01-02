// Copyright 2023 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dart_wot/scripting_api.dart";
import "package:test/test.dart";

void main() {
  group("DataSchemaValue", () {
    test("should use the wrapped value for toString()", () {
      const inputValue = 42;
      final dataSchemaValue = DataSchemaValue.fromNumber(inputValue);

      expect(dataSchemaValue.toString() == inputValue.toString(), isTrue);
    });
  });
}
