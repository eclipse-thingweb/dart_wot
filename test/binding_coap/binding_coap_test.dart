// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dart_wot/binding_coap.dart";
import "package:dart_wot/core.dart";

import "package:test/test.dart";

void main() {
  group("CoAP Binding Tests", () {
    setUp(() {
      // Additional setup goes here.
    });

    test("Server tests", () {
      final defaultServer = CoapServer();
      final servient = Servient.create(
        servers: [
          defaultServer,
        ],
      );

      expect(defaultServer.port, 5683);
      expect(defaultServer.scheme, "coap");

      expect(
        () async => defaultServer.start(servient),
        throwsA(const TypeMatcher<UnimplementedError>()),
      );
      expect(
        () async => defaultServer.stop(),
        throwsA(const TypeMatcher<UnimplementedError>()),
      );

      final customServer =
          CoapServer(const CoapConfig(port: 9001, blocksize: 64));

      expect(customServer.port, 9001);
      expect(customServer.preferredBlockSize, 64);
    });

    test("ClientFactory tests", () async {
      final defaultClientFactory = CoapClientFactory();

      expect(defaultClientFactory.coapConfig, null);
      expect(defaultClientFactory.init(), true);

      final coapClient = defaultClientFactory.createClient();

      await coapClient.start();

      await coapClient.stop();

      expect(defaultClientFactory.destroy(), true);

      final customClientFactory = CoapClientFactory(
        coapConfig: const CoapConfig(port: 9001, blocksize: 64),
      );

      expect(customClientFactory.coapConfig?.port, 9001);
      expect(customClientFactory.coapConfig?.blocksize, 64);

      expect(customClientFactory.init(), true);
      expect(customClientFactory.destroy(), true);
    });
  });
}
