// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dart_wot/core.dart";
import "package:test/test.dart";

void main() {
  group("OperationType should indicate the correct default op values for", () {
    test("properties", () {
      const regularProperty = Property(forms: []);

      final regularPropertyOpValues =
          OperationType.defaultOpValues(regularProperty);
      expect(regularPropertyOpValues, [
        OperationType.writeproperty,
        OperationType.readproperty,
      ]);

      const writeOnlyProperty = Property(
        forms: [],
        dataSchema: DataSchema(writeOnly: true),
      );

      final writeOnlyPropertyOpValues =
          OperationType.defaultOpValues(writeOnlyProperty);
      expect(writeOnlyPropertyOpValues, [
        OperationType.writeproperty,
      ]);

      const readOnlyProperty = Property(
        forms: [],
        dataSchema: DataSchema(readOnly: true),
      );

      final readOnlyPropertyOpValues =
          OperationType.defaultOpValues(readOnlyProperty);
      expect(readOnlyPropertyOpValues, [
        OperationType.readproperty,
      ]);
    });

    test("actions", () {
      const regularAction = Action(forms: []);

      final regularActionOpValues =
          OperationType.defaultOpValues(regularAction);
      expect(regularActionOpValues, [
        OperationType.invokeaction,
      ]);
    });

    test("events", () {
      const regularEvent = Event(forms: []);

      final regularEventOpValues = OperationType.defaultOpValues(regularEvent);
      expect(regularEventOpValues, [
        OperationType.subscribeevent,
        OperationType.unsubscribeevent,
      ]);
    });
  });
}
