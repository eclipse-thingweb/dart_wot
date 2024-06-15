// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "../definitions.dart";
import "../protocol_interfaces/exposable_thing.dart";
import "../scripting_api.dart" as scripting_api;

import "content.dart";
import "interaction_output.dart";
import "servient.dart";

/// Implementation of the [scripting_api.ExposedThing] interface.
class ExposedThing implements scripting_api.ExposedThing, ExposableThing {
  /// Creates a new [ExposedThing] from a [_servient] and an [exposedThingInit].
  ExposedThing(this._servient, scripting_api.ExposedThingInit exposedThingInit)
      : thingDescription = ThingDescription.fromJson(exposedThingInit);

  @override
  final ThingDescription thingDescription;

  /// The [Servient] associated with this [ExposedThing].
  final InternalServient _servient;

  final Map<String, scripting_api.PropertyReadHandler> _propertyReadHandlers =
      {};

  final Map<String, scripting_api.PropertyWriteHandler> _propertyWriteHandlers =
      {};

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
    _propertyWriteHandlers[name] = handler;
  }

  @override
  Future<void> destroy() async {
    _servient.destroyThing(this);
  }

  @override
  Future<void> emitEvent(String name, Object? data) {
    // TODO(JKRhb): implement emitEvent
    throw UnimplementedError();
  }

  @override
  Future<void> expose() => _servient.expose(this);

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
    // TODO: Ensure that the property is actually readable.
    _propertyReadHandlers[name] = handler;
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

  @override
  Future<Content> handleReadProperty(
    String propertyName, {
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  }) async {
    final readHandler = _propertyReadHandlers[propertyName];

    if (readHandler == null) {
      throw Exception(
        "Read handler for property $propertyName is not defined.",
      );
    }

    final interactionInput = await readHandler(
      data: data,
      uriVariables: uriVariables,
      formIndex: formIndex,
    );

    return Content.fromInteractionInput(
      interactionInput,
      "application/json",
      _servient.contentSerdes,
      thingDescription.properties?[propertyName],
    );
  }

  @override
  Future<void> handleWriteProperty(
    String propertyName,
    Content input, {
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  }) async {
    final writeHandler = _propertyWriteHandlers[propertyName];

    if (writeHandler == null) {
      throw Exception(
        "Write handler for property $propertyName is not defined.",
      );
    }

    final Form form;

    if (formIndex == null) {
      // FIXME: Returning a form does not really make sense here.
      form = Form(Uri.parse("hi"));
    } else {
      form = thingDescription.properties?[propertyName]?.forms
              .elementAtOrNull(formIndex) ??
          Form(Uri.parse("hi"));
    }

    await writeHandler(
      InteractionOutput(
        input,
        _servient.contentSerdes,
        form,
        thingDescription.properties?[propertyName],
      ),
      formIndex: formIndex,
      uriVariables: uriVariables,
      data: data,
    );
  }
}
