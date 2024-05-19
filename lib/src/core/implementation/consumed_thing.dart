// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "../definitions.dart";
import "../exceptions.dart";
import "../scripting_api.dart" as scripting_api;
import "augmented_form.dart";
import "content.dart";
import "interaction_output.dart";
import "protocol_interfaces/protocol_client.dart";
import "servient.dart";

/// Implementation of the [scripting_api.ConsumedThing] interface.
class ConsumedThing implements scripting_api.ConsumedThing {
  /// Constructor
  ConsumedThing(this.servient, this.thingDescription)
      : title = thingDescription.title;

  /// The [Servient] corresponding with this [ConsumedThing].
  final InternalServient servient;

  @override
  final ThingDescription thingDescription;

  /// The [title] of the Thing.
  final String title;

  final Map<String, scripting_api.Subscription> _subscribedEvents = {};

  final Map<String, scripting_api.Subscription> _observedProperties = {};

  /// Determines the id of this [ConsumedThing].
  String get identifier => thingDescription.identifier;

  (ProtocolClient client, AugmentedForm form) _getClientFor(
    List<Form> forms,
    OperationType operationType,
    InteractionAffordance interactionAffordance, {
    required int? formIndex,
    required Map<String, Object>? uriVariables,
  }) {
    final augmentedForms = forms
        .map(
          (form) => AugmentedForm.new(
            form,
            interactionAffordance,
            thingDescription,
            uriVariables,
          ),
        )
        .toList();
    final ProtocolClient client;
    final AugmentedForm foundForm;

    if (formIndex != null) {
      if (formIndex >= 0 && formIndex < forms.length) {
        foundForm = augmentedForms[formIndex];
        final scheme = foundForm.href.scheme;
        client = servient.clientFor(scheme);
      } else {
        throw ArgumentError(
          'ConsumedThing "$title" missing formIndex for '
              '$formIndex"',
          "options.formIndex",
        );
      }
    } else {
      foundForm = augmentedForms.firstWhere(
        (form) {
          final opValues = form.op;

          if (!opValues.contains(operationType)) {
            return false;
          }

          return servient.supportsOperation(
            form.resolvedHref.scheme,
            operationType,
            form.subprotocol,
          );
        },
        // TODO(JKRhb): Add custom Exception
        orElse: () => throw Exception("No matching form found!"),
      );
      final scheme = foundForm.href.scheme;
      client = servient.clientFor(scheme);
    }

    return (client, foundForm);
  }

  @override
  Future<InteractionOutput> readProperty(
    String propertyName, {
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  }) async {
    final property = thingDescription.properties?[propertyName];

    if (property == null) {
      throw ArgumentError(
        "ConsumedThing $title does not have property $propertyName",
        "propertyName",
      );
    }

    final (ProtocolClient client, AugmentedForm form) = _getClientFor(
      property.forms,
      OperationType.readproperty,
      property,
      formIndex: formIndex,
      uriVariables: uriVariables,
    );

    final content = await client.readResource(form);
    return InteractionOutput(content, servient.contentSerdes, form, property);
  }

  @override
  Future<void> writeProperty(
    String propertyName,
    scripting_api.InteractionInput? input, {
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  }) async {
    final property = thingDescription.properties?[propertyName];

    if (property == null) {
      throw ArgumentError(
        "ConsumedThing $title does not have property $propertyName",
        "propertyName",
      );
    }

    final (client, form) = _getClientFor(
      property.forms,
      OperationType.writeproperty,
      property,
      formIndex: formIndex,
      uriVariables: uriVariables,
    );

    final content = Content.fromInteractionInput(
      input,
      form.contentType,
      servient.contentSerdes,
      property,
    );

    await client.writeResource(form, content);
  }

  @override
  Future<InteractionOutput> invokeAction(
    String actionName, {
    scripting_api.InteractionInput? input,
    Object? data,
    int? formIndex,
    Map<String, Object>? uriVariables,
  }) async {
    // TODO(JKRhb): Refactor
    final action = thingDescription.actions?[actionName];

    if (action == null) {
      throw ArgumentError(
        "ConsumedThing $title does not have action $actionName",
        "actionName",
      );
    }

    final (client, form) = _getClientFor(
      action.forms,
      OperationType.invokeaction,
      action,
      uriVariables: uriVariables,
      formIndex: formIndex,
    );

    final content = Content.fromInteractionInput(
      input,
      form.contentType,
      servient.contentSerdes,
      action.input,
    );

    final output = await client.invokeResource(form, content);

    final response = form.response;
    if (response != null) {
      final outputType = output.type;
      final responseType = response.contentType;
      if (output.type != response.contentType) {
        throw DartWotException(
          "Unexpected output type $outputType in response, "
          "expected $responseType.",
        );
      }
    }

    return InteractionOutput(
      output,
      servient.contentSerdes,
      form,
      action.output,
    );
  }

  @override
  Future<scripting_api.Subscription> observeProperty(
    String propertyName,
    scripting_api.InteractionListener listener, {
    scripting_api.ErrorListener? onError,
    Object? data,
    int? formIndex,
    Map<String, Object>? uriVariables,
  }) async {
    final property = thingDescription.properties?[propertyName];

    if (property == null) {
      throw ArgumentError(
        "ConsumedThing $title does not have property $propertyName",
        "propertyName",
      );
    }

    if (_observedProperties.containsKey(propertyName)) {
      throw StateError(
        "ConsumedThing '$title' already has a function "
        "subscribed to $propertyName. You can only observe once",
      );
    }

    return _createSubscription(
      property,
      listener,
      onError,
      propertyName,
      property,
      scripting_api.SubscriptionType.property,
      formIndex: formIndex,
      uriVariables: uriVariables,
    );
  }

  Future<scripting_api.Subscription> _createSubscription(
    InteractionAffordance affordance,
    scripting_api.InteractionListener listener,
    scripting_api.ErrorListener? onError,
    String affordanceName,
    DataSchema? dataSchema,
    scripting_api.SubscriptionType subscriptionType, {
    required int? formIndex,
    required Map<String, Object>? uriVariables,
  }) async {
    final OperationType operationType;
    final Map<String, scripting_api.Subscription> subscriptions;

    switch (subscriptionType) {
      case scripting_api.SubscriptionType.property:
        operationType = OperationType.observeproperty;
        subscriptions = _observedProperties;
      case scripting_api.SubscriptionType.event:
        operationType = OperationType.subscribeevent;
        subscriptions = _subscribedEvents;
    }

    final (client, form) = _getClientFor(
      affordance.forms,
      operationType,
      affordance,
      uriVariables: uriVariables,
      formIndex: formIndex,
    );

    final subscription = await client.subscribeResource(
      form,
      next: (content) => listener(
        InteractionOutput(content, servient.contentSerdes, form, dataSchema),
      ),
      error: (error) {
        if (onError != null) {
          onError(error);
        }
      },
      complete: () => removeSubscription(affordanceName, subscriptionType),
    );

    switch (subscriptionType) {
      case scripting_api.SubscriptionType.property:
        _observedProperties[affordanceName] = subscription;
      case scripting_api.SubscriptionType.event:
        _subscribedEvents[affordanceName] = subscription;
    }

    subscriptions[affordanceName] = subscription;

    return subscription;
  }

  Future<scripting_api.PropertyReadMap> _readProperties(
    List<String> propertyNames, {
    Object? data,
    int? formIndex,
    Map<String, Object>? uriVariables,
  }) async {
    final Map<String, Future<InteractionOutput>> outputs = {};

    for (final propertyName in propertyNames) {
      outputs[propertyName] = readProperty(
        propertyName,
        data: data,
        formIndex: formIndex,
        uriVariables: uriVariables,
      );
    }

    final outputList = await Future.wait(outputs.values);

    return Map.fromIterables(outputs.keys, outputList);
  }

  @override
  Future<scripting_api.PropertyReadMap> readAllProperties({
    Object? data,
    int? formIndex,
    Map<String, Object>? uriVariables,
  }) {
    final propertyNames =
        thingDescription.properties?.keys.toList(growable: false) ?? [];

    return _readProperties(
      propertyNames,
      data: data,
      formIndex: formIndex,
      uriVariables: uriVariables,
    );
  }

  @override
  Future<scripting_api.PropertyReadMap> readMultipleProperties(
    List<String> propertyNames, {
    Object? data,
    int? formIndex,
    Map<String, Object>? uriVariables,
  }) {
    return _readProperties(
      propertyNames,
      data: data,
      formIndex: formIndex,
      uriVariables: uriVariables,
    );
  }

  @override
  Future<scripting_api.Subscription> subscribeEvent(
    String eventName,
    scripting_api.InteractionListener listener, {
    scripting_api.ErrorListener? onError,
    Object? data,
    int? formIndex,
    Map<String, Object>? uriVariables,
  }) {
    // TODO(JKRhb): Handle subscription and cancellation data.
    final event = thingDescription.events?[eventName];

    if (event == null) {
      throw ArgumentError(
        "ConsumedThing $title does not have event $eventName",
        "eventName",
      );
    }

    if (_subscribedEvents.containsKey(eventName)) {
      throw DartWotException(
        "ConsumedThing '$title' already has a function "
        "subscribed to $eventName. You can only subscribe once.",
      );
    }

    return _createSubscription(
      event,
      listener,
      onError,
      eventName,
      event.data,
      scripting_api.SubscriptionType.event,
      formIndex: formIndex,
      uriVariables: uriVariables,
    );
  }

  @override
  Future<void> writeMultipleProperties(
    scripting_api.PropertyWriteMap valueMap, {
    Object? data,
    int? formIndex,
    Map<String, Object>? uriVariables,
  }) async {
    await Future.wait(
      valueMap.keys.map((key) => writeProperty(key, valueMap[key])),
    );
  }

  /// Removes a subscription with a specified [key] and [type].
  void removeSubscription(String key, scripting_api.SubscriptionType type) {
    switch (type) {
      case scripting_api.SubscriptionType.property:
        _observedProperties.remove(key);
      case scripting_api.SubscriptionType.event:
        _subscribedEvents.remove(key);
    }
  }

  /// Cleans up the resources used by this [ConsumedThing].
  bool destroy({bool external = true}) {
    for (final observedProperty in _observedProperties.values) {
      observedProperty.stop();
    }
    _observedProperties.clear();
    for (final subscribedEvent in _subscribedEvents.values) {
      subscribedEvent.stop();
    }
    _subscribedEvents.clear();

    if (external) {
      return servient.deregisterConsumedThing(this);
    }

    return false;
  }
}
