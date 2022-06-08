// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../../definitions.dart';
import '../../scripting_api.dart' hide ExposedThing;
import '../../scripting_api.dart' as scripting_api;
import '../definitions/interaction_affordances/action.dart';
import '../definitions/interaction_affordances/event.dart';
import '../definitions/interaction_affordances/property.dart';
import 'servient.dart';

/// Implemention of the [scripting_api.ExposedThing] interface.
class ExposedThing implements scripting_api.ExposedThing {
  @override
  final ThingDescription thingDescription;

  /// The [Servient] associated with this [ExposedThing].
  final Servient servient;

  /// A unique identifier of this [ExposedThing].
  String? id;

  /// The title of the Thing.
  String? title;

  /// A [Map] of all the [properties] of this [ExposedThing].
  final Map<String, Property>? properties = {};

  /// A [Map] of all the [actions] of this [ExposedThing].
  final Map<String, Action>? actions = {};

  /// A [Map] of all the [events] of this [ExposedThing].
  final Map<String, Event>? events = {};

  /// Creates a new [ExposedThing] from a [servient] and an [exposedThingInit].
  ExposedThing(this.servient, ExposedThingInit exposedThingInit)
      : thingDescription =
            ThingDescription.fromJson(exposedThingInit, validate: false) {
    title = thingDescription.title;
    id = thingDescription.id;
  }

  /// Creates an [ExposedThing] from a [ThingModel].
  ///
  // TODO(JKRhb): Additional parameters for bindings etc. might be needed
  ExposedThing.fromThingModel(this.servient, ThingModel thingModel)
      : thingDescription = ThingDescription.fromThingModel(thingModel) {
    title = thingDescription.title;
    id = thingDescription.id;
  }

  @override
  Future<void> emitPropertyChange(String name) {
    // TODO(JKRhb): implement emitPropertyChange
    throw UnimplementedError();
  }

  @override
  void setPropertyWriteHandler(String name, PropertyWriteHandler handler) {
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
  void setEventUnsubscribeHandler(
      String name, EventSubscriptionHandler handler) {
    // TODO(JKRhb): implement setEventUnsubscribeHandler
  }
}
