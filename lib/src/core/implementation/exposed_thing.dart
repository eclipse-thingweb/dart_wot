// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "../definitions.dart";
import "../scripting_api.dart" as scripting_api;

import "servient.dart";

/// Implementation of the [scripting_api.ExposedThing] interface.
class ExposedThing implements scripting_api.ExposedThing {
  /// Creates a new [ExposedThing] from a [servient] and an [exposedThingInit].
  ExposedThing(this.servient, scripting_api.ExposedThingInit exposedThingInit)
      : thingDescription = ThingDescription.fromJson(exposedThingInit);

  @override
  final ThingDescription thingDescription;

  /// The [Servient] associated with this [ExposedThing].
  final Servient servient;

  /// A [Map] of all the [properties] of this [ExposedThing].
  final Map<String, Property>? properties = {};

  /// A [Map] of all the [actions] of this [ExposedThing].
  final Map<String, Action>? actions = {};

  /// A [Map] of all the [events] of this [ExposedThing].
  final Map<String, Event>? events = {};

  @override
  Future<void> emitPropertyChange(String name) {
    // TODO(JKRhb): implement emitPropertyChange
    throw UnimplementedError();
  }

  @override
  void setPropertyWriteHandler(
    String name,
    scripting_api.PropertyWriteHandler handler,
  ) {
    // TODO(JKRhb): implement setPropertyWriteHandler
  }

  @override
  Future<void> destroy() {
    // TODO(JKRhb): implement destroy
    throw UnimplementedError();
  }

  @override
  Future<void> emitEvent(String name, Object? data) {
    // TODO(JKRhb): implement emitEvent
    throw UnimplementedError();
  }

  @override
  Future<void> expose() {
    // TODO(JKRhb): implement expose
    throw UnimplementedError();
  }

  @override
  void setActionHandler(String name, scripting_api.ActionHandler handler) {
    // TODO(JKRhb): implement setActionHandler
  }

  @override
  void setEventHandler(
    String name,
    scripting_api.EventListenerHandler handler,
  ) {
    // TODO(JKRhb): implement setEventHandler
  }

  @override
  void setEventSubscribeHandler(
    String name,
    scripting_api.EventSubscriptionHandler handler,
  ) {
    // TODO(JKRhb): implement setEventSubscribeHandler
  }

  @override
  void setPropertyObserveHandler(
    String name,
    scripting_api.PropertyReadHandler handler,
  ) {
    // TODO(JKRhb): implement setPropertyObserveHandler
  }

  @override
  void setPropertyReadHandler(
    String name,
    scripting_api.PropertyReadHandler handler,
  ) {
    // TODO(JKRhb): implement setPropertyReadHandler
  }

  @override
  void setPropertyUnobserveHandler(
    String name,
    scripting_api.PropertyReadHandler handler,
  ) {
    // TODO(JKRhb): implement setPropertyUnobserveHandler
  }

  @override
  void setEventUnsubscribeHandler(
    String name,
    scripting_api.EventSubscriptionHandler handler,
  ) {
    // TODO(JKRhb): implement setEventUnsubscribeHandler
  }
}
