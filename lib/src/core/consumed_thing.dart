// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "../../scripting_api.dart" as scripting_api;
import "../../scripting_api.dart" hide ConsumedThing, InteractionOutput;
import "../definitions/data_schema.dart";
import "../definitions/form.dart";
import "../definitions/interaction_affordances/interaction_affordance.dart";
import "../definitions/operation_type.dart";
import "../definitions/thing_description.dart";
import "augmented_form.dart";
import "content.dart";
import "interaction_output.dart";
import "protocol_interfaces/protocol_client.dart";
import "servient.dart";

/// This [Exception] is thrown when the body of a response is encoded
/// differently than expected.
class UnexpectedReponseException implements Exception {
  /// Creates a new [UnexpectedReponseException] from an error [message].
  UnexpectedReponseException(this.message);

  /// The error [message].
  final String message;

  @override
  String toString() => "UnexpectedReponseException: $message";
}

/// This Exception is thrown when
class SubscriptionException implements Exception {
  /// Creates a new [SubscriptionException] from an error [message].
  SubscriptionException(this.message);

  /// The error [message].
  final String message;

  @override
  String toString() => "SubscriptionException: $message";
}

/// Implementation of the [scripting_api.ConsumedThing] interface.
class ConsumedThing implements scripting_api.ConsumedThing {
  /// Constructor
  ConsumedThing(this.servient, this.thingDescription)
      : title = thingDescription.title;

  /// The [Servient] corresponding with this [ConsumedThing].
  final Servient servient;

  @override
  final ThingDescription thingDescription;

  /// The [title] of the Thing.
  final String title;

  final Map<String, scripting_api.Subscription> _subscribedEvents = {};

  final Map<String, scripting_api.Subscription> _observedProperties = {};

  /// Determines the id of this [ConsumedThing].
  String get identifier => thingDescription.identifier;

  /// Checks if the [Servient] of this [ConsumedThing] supports a protocol
  /// [scheme].
  bool hasClientFor(String scheme) => servient.hasClientFor(scheme);

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
        (form) =>
            hasClientFor(form.href.scheme) &&
            _supportsOperationType(form, interactionAffordance, operationType),
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
    InteractionInput? input, {
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
    InteractionInput? input,
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
      if (output.type != response.contentType) {
        throw UnexpectedReponseException("Unexpected type in response");
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
  Future<Subscription> observeProperty(
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
      SubscriptionType.property,
      formIndex: formIndex,
      uriVariables: uriVariables,
    );
  }

  Future<Subscription> _createSubscription(
    InteractionAffordance affordance,
    scripting_api.InteractionListener listener,
    scripting_api.ErrorListener? onError,
    String affordanceName,
    DataSchema? dataSchema,
    SubscriptionType subscriptionType, {
    required int? formIndex,
    required Map<String, Object>? uriVariables,
  }) async {
    final OperationType operationType;
    final Map<String, Subscription> subscriptions;

    switch (subscriptionType) {
      case SubscriptionType.property:
        operationType = OperationType.observeproperty;
        subscriptions = _observedProperties;
      case SubscriptionType.event:
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
      case SubscriptionType.property:
        _observedProperties[affordanceName] = subscription;
      case SubscriptionType.event:
        _subscribedEvents[affordanceName] = subscription;
    }

    subscriptions[affordanceName] = subscription;

    return subscription;
  }

  Future<PropertyReadMap> _readProperties(
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
  Future<PropertyReadMap> readAllProperties({
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
  Future<PropertyReadMap> readMultipleProperties(
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
  Future<Subscription> subscribeEvent(
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
      throw SubscriptionException(
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
      SubscriptionType.event,
      formIndex: formIndex,
      uriVariables: uriVariables,
    );
  }

  @override
  Future<void> writeMultipleProperties(
    PropertyWriteMap valueMap, {
    Object? data,
    int? formIndex,
    Map<String, Object>? uriVariables,
  }) async {
    await Future.wait(
      valueMap.keys.map((key) => writeProperty(key, valueMap[key])),
    );
  }

  /// Removes a subscription with a specified [key] and [type].
  void removeSubscription(String key, SubscriptionType type) {
    switch (type) {
      case SubscriptionType.property:
        _observedProperties.remove(key);
      case SubscriptionType.event:
        _subscribedEvents.remove(key);
    }
  }

  static bool _supportsOperationType(
    Form form,
    InteractionAffordance interactionAffordance,
    OperationType operationType,
  ) {
    final opValues =
        form.op ?? OperationType.defaultOpValues(interactionAffordance);

    return opValues.contains(operationType);
  }

  /// Cleans up the resources used by this [ConsumedThing].
  void destroy() {
    for (final observedProperty in _observedProperties.values) {
      observedProperty.stop();
    }
    _observedProperties.clear();
    for (final subscribedEvent in _subscribedEvents.values) {
      subscribedEvent.stop();
    }
    _subscribedEvents.clear();
  }
}
