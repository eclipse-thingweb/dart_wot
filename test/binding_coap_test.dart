// Copyright 2022 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import 'package:dart_wot/dart_wot.dart';
import 'package:test/test.dart';

class MockedExposedThing implements ExposedThing {
  @override
  Future<void> destroy() {
    // TODO(JKRhb): implement destroy
    throw UnimplementedError();
  }

  @override
  Future<void> emitEvent(String name, InteractionInput? data) {
    // TODO(JKRhb): implement emitEvent
    throw UnimplementedError();
  }

  @override
  Future<void> emitPropertyChange(String name) {
    // TODO(JKRhb): implement emitPropertyChange
    throw UnimplementedError();
  }

  @override
  Future<void> expose() {
    // TODO(JKRhb): implement expose
    throw UnimplementedError();
  }

  @override
  void setActionHandler(String name, ActionHandler handler) {
    // TODO(JKRhb): implement setActionHandler
  }

  @override
  void setEventHandler(String name, EventListenerHandler handler) {
    // TODO(JKRhb): implement setEventHandler
  }

  @override
  void setEventSubscribeHandler(String name, EventSubscriptionHandler handler) {
    // TODO(JKRhb): implement setEventSubscribeHandler
  }

  @override
  void setEventUnsubscribeHandler(
      String name, EventSubscriptionHandler handler) {
    // TODO(JKRhb): implement setEventUnsubscribeHandler
  }

  @override
  void setPropertyObserveHandler(String name, PropertyReadHandler handler) {
    // TODO(JKRhb): implement setPropertyObserveHandler
  }

  @override
  void setPropertyReadHandler(String name, PropertyReadHandler handler) {
    // TODO(JKRhb): implement setPropertyReadHandler
  }

  @override
  void setPropertyUnobserveHandler(String name, PropertyReadHandler handler) {
    // TODO(JKRhb): implement setPropertyUnobserveHandler
  }

  @override
  void setPropertyWriteHandler(String name, PropertyWriteHandler handler) {
    // TODO(JKRhb): implement setPropertyWriteHandler
  }

  @override
  // TODO(JKRhb): implement thingDescription
  ThingDescription get thingDescription => throw UnimplementedError();
}

void main() {
  group('CoAP Binding Tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test("Server tests", () {
      final defaultServer = CoapServer(null);

      expect(defaultServer.port, 5683);
      expect(defaultServer.scheme, "coap");

      expect(() async => await defaultServer.start({}),
          throwsA(TypeMatcher<UnimplementedError>()));
      expect(() async => await defaultServer.stop(),
          throwsA(TypeMatcher<UnimplementedError>()));
      expect(() async => await defaultServer.expose(MockedExposedThing()),
          throwsA(TypeMatcher<UnimplementedError>()));

      final customServer = CoapServer(CoapConfig(port: 9001, blocksize: 64));

      expect(customServer.port, 9001);
      expect(customServer.preferredBlockSize, 64);
    });

    test("ClientFactory tests", () {
      final defaultCientFactory = CoapClientFactory(null);

      expect(defaultCientFactory.coapConfig, null);

      final customCientFactory =
          CoapClientFactory(CoapConfig(port: 9001, blocksize: 64));

      expect(customCientFactory.coapConfig?.port, 9001);
      expect(customCientFactory.coapConfig?.blocksize, 64);
    });
  });
}
