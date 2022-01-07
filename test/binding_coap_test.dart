// Copyright 2022 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import 'package:dart_wot/binding_coap.dart';
import 'package:test/test.dart';

void main() {
  group('CoAP Binding Tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test("Server tests", () {
      final server = CoapServer(null);

      expect(server.port, 5683);
      expect(server.scheme, "coap");
    });
  });
}
