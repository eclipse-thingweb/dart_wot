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

  final Map<String, scripting_api.PropertyReadHandler>
      _propertyObserveHandlers = {};

  final Map<String, scripting_api.PropertyReadHandler>
      _propertyUnobserveHandlers = {};

  final Map<String, scripting_api.ActionHandler> _actionHandlers = {};

  Property _obtainProperty(String name) {
    final property = thingDescription.properties?[name];

    if (property == null) {
      throw ArgumentError(
        "Property $name does not exist in ExposedThing "
        "with title ${thingDescription.title}.",
      );
    }

    return property;
  }

  void _checkReadableProperty(String name) {
    final property = _obtainProperty(name);

    if (property.writeOnly) {
      final title = property.title ?? "without title";
      throw ArgumentError("Property $title is not readable.");
    }
  }

  void _checkWritableProperty(String name) {
    final property = _obtainProperty(name);

    if (property.readOnly) {
      final title = property.title ?? "without title";
      throw ArgumentError("Property $title is not writable.");
    }
  }

  void _checkObservableProperty(String name) {
    final property = _obtainProperty(name);

    if (!property.observable) {
      final title = property.title ?? "without title";
      throw ArgumentError("Property $title is not observable.");
    }
  }

  @override
  Future<void> emitPropertyChange(String name) {
    // TODO(JKRhb): implement emitPropertyChange
    throw UnimplementedError();
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
    if (thingDescription.actions?[name] == null) {
      throw ArgumentError("ExposedThing does not an Action with the key $name");
    }

    _actionHandlers[name] = handler;
  }

  @override
  void setPropertyReadHandler(
    String name,
    scripting_api.PropertyReadHandler handler,
  ) {
    _checkReadableProperty(name);

    _propertyReadHandlers[name] = handler;
  }

  @override
  void setPropertyWriteHandler(
    String name,
    scripting_api.PropertyWriteHandler handler,
  ) {
    _checkWritableProperty(name);

    _propertyWriteHandlers[name] = handler;
  }

  @override
  void setPropertyObserveHandler(
    String name,
    scripting_api.PropertyReadHandler handler,
  ) {
    _checkObservableProperty(name);

    _propertyObserveHandlers[name] = handler;
  }

  @override
  void setPropertyUnobserveHandler(
    String name,
    scripting_api.PropertyReadHandler handler,
  ) {
    _checkObservableProperty(name);

    _propertyUnobserveHandlers[name] = handler;
  }

  @override
  void setEventSubscribeHandler(
    String name,
    scripting_api.EventSubscriptionHandler handler,
  ) {
    // TODO(JKRhb): implement setEventSubscribeHandler
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

  @override
  Future<Content?> handleInvokeAction(
    String actionName,
    Content input, {
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  }) async {
    final actionHandler = _actionHandlers[actionName];

    if (actionHandler == null) {
      throw Exception(
        "Action handler for action $actionName is not defined.",
      );
    }

    final action = thingDescription.actions?[actionName];

    final processedInput = InteractionOutput(
      input,
      _servient.contentSerdes,
      // FIXME: Providing a form does not really make sense here.
      Form(Uri()),
      action?.input,
    );

    final actionOutput = await actionHandler(
      processedInput,
      formIndex: formIndex,
      uriVariables: uriVariables,
      data: data,
    );

    return Content.fromInteractionInput(
      actionOutput,
      "application/json",
      _servient.contentSerdes,
      null,
    );
  }

  @override
  Stream<Content> handleObserveProperty(
    String eventName, {
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  }) {
    // TODO: implement handleObserveProperty
    throw UnimplementedError();
  }

  @override
  Future<void> handleReadAllProperties(
    List<String> propertyNames,
    PropertyContentMap inputs, {
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  }) {
    // TODO: implement handleReadAllProperties
    throw UnimplementedError();
  }

  @override
  Future<PropertyContentMap> handleReadMultipleProperties(
    List<String> propertyNames,
    Content input, {
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  }) {
    // TODO: implement handleReadMultipleProperties
    throw UnimplementedError();
  }

  @override
  Stream<Content> handleSubscribeEvent(
    String eventName, {
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  }) {
    // TODO: implement handleSubscribeEvent
    throw UnimplementedError();
  }

  @override
  Future<void> handleUnsubscribeEvent(
    String eventName, {
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  }) {
    // TODO: implement handleUnsubscribeEvent
    throw UnimplementedError();
  }

  @override
  Future<void> handleWriteMultipleProperties(
    List<String> propertyNames,
    Content input, {
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  }) {
    // TODO: implement handleWriteMultipleProperties
    throw UnimplementedError();
  }

  @override
  Future<void> handleUnobserveProperty(
    String eventName, {
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  }) {
    // TODO: implement handleUnobserveProperty
    throw UnimplementedError();
  }
}
