// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/dart_wot.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';
import 'binding_coap_test.mocks.dart';

@GenerateMocks([ExposedThing])
void main() {
  group('CoAP Binding Tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Server tests', () {
      final defaultServer = CoapServer();

      expect(defaultServer.port, 5683);
      expect(defaultServer.scheme, 'coap');

      expect(
        () async => defaultServer.start(),
        throwsA(const TypeMatcher<UnimplementedError>()),
      );
      expect(
        () async => defaultServer.stop(),
        throwsA(const TypeMatcher<UnimplementedError>()),
      );
      expect(
        () async => defaultServer.expose(MockExposedThing()),
        throwsA(const TypeMatcher<UnimplementedError>()),
      );

      final customServer = CoapServer(CoapConfig(port: 9001, blocksize: 64));

      expect(customServer.port, 9001);
      expect(customServer.preferredBlockSize, 64);
    });

    test('ClientFactory tests', () async {
      final defaultClientFactory = CoapClientFactory();

      expect(defaultClientFactory.coapConfig, null);
      expect(defaultClientFactory.init(), true);

      final coapClient = defaultClientFactory.createClient();

      await coapClient.start();

      await coapClient.stop();

      expect(defaultClientFactory.destroy(), true);

      final customClientFactory =
          CoapClientFactory(CoapConfig(port: 9001, blocksize: 64));

      expect(customClientFactory.coapConfig?.port, 9001);
      expect(customClientFactory.coapConfig?.blocksize, 64);

      expect(customClientFactory.init(), true);
      expect(customClientFactory.destroy(), true);
    });
  });
}
