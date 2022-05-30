// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../../scripting_api.dart' as scripting_api;
import '../../scripting_api.dart' hide ConsumedThing, InteractionOutput;
import '../definitions/data_schema.dart';
import '../definitions/form.dart';
import '../definitions/interaction_affordances/interaction_affordance.dart';
import '../definitions/thing_description.dart';
import 'interaction_output.dart';
import 'operation_type.dart';
import 'protocol_interfaces/protocol_client.dart';
import 'servient.dart';

enum _AffordanceType {
  action,
  property,
  event,
}

/// This [Exception] is thrown when the body of a response is encoded
/// differently than expected.
class UnexpectedReponseException implements Exception {
  /// The error [message].
  final String message;

  /// Creates a new [UnexpectedReponseException] from an error [message].
  UnexpectedReponseException(this.message);
}

/// Implementation of the [scripting_api.ConsumedThing] interface.
class ConsumedThing implements scripting_api.ConsumedThing {
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

  /// Constructor
  ConsumedThing(this.servient, this.thingDescription)
      : title = thingDescription.title;

  /// Checks if the [Servient] of this [ConsumedThing] supports a protocol
  /// [scheme].
  bool hasClientFor(String scheme) => servient.hasClientFor(scheme);

  _ClientAndForm _getClientFor(
      List<Form> forms,
      OperationType operationType,
      _AffordanceType affordanceType,
      InteractionOptions? options,
      InteractionAffordance interactionAffordance) {
    if (forms.isEmpty) {
      throw ArgumentError(
          'ConsumedThing "$title" has no links for this interaction');
    }

    final ProtocolClient client;
    final Form foundForm;

    final int? formIndex = options?.formIndex;

    if (formIndex != null) {
      if (formIndex >= 0 && formIndex < forms.length) {
        foundForm = forms[formIndex];
        final scheme = foundForm.resolvedHref.scheme;
        client = servient.clientFor(scheme);
      } else {
        throw ArgumentError('ConsumedThing "$title" missing formIndex for '
            '$formIndex"');
      }
    } else {
      foundForm = forms.firstWhere(
          (form) =>
              hasClientFor(form.resolvedHref.scheme) &&
              _supportsOperationType(form, affordanceType, operationType),
          // TODO(JKRhb): Add custom Exception
          orElse: () => throw Exception("No matching form found!"));
      final scheme = foundForm.resolvedHref.scheme;
      client = servient.clientFor(scheme);
    }

    final form = foundForm.resolveUriVariables(options?.uriVariables);

    return _ClientAndForm(client, form);
  }

  @override
  Future<InteractionOutput> readProperty(String propertyName,
      [InteractionOptions? options]) async {
    final property = thingDescription.properties[propertyName];

    if (property == null) {
      throw StateError(
          'ConsumedThing $title does not have property $propertyName');
    }

    final clientAndForm = _getClientFor(
        property.forms,
        OperationType.readproperty,
        _AffordanceType.property,
        options,
        property);

    final form = clientAndForm.form;
    final client = clientAndForm.client;

    final content = await client.readResource(form);
    return InteractionOutput(content, servient.contentSerdes, form, property);
  }

  @override
  Future<void> writeProperty(String propertyName, Object? interactionInput,
      [InteractionOptions? options]) async {
    // TODO(JKRhb): Refactor
    final property = thingDescription.properties[propertyName];

    if (property == null) {
      throw StateError(
          'ConsumedThing $title does not have property $propertyName');
    }

    final clientAndForm = _getClientFor(
        property.forms,
        OperationType.writeproperty,
        _AffordanceType.property,
        options,
        property);

    final form = clientAndForm.form;
    final client = clientAndForm.client;
    final content = servient.contentSerdes
        .valueToContent(interactionInput, property, form.contentType);
    await client.writeResource(form, content);
  }

  @override
  Future<InteractionOutput> invokeAction(String actionName,
      [Object? interactionInput, InteractionOptions? options]) async {
    // TODO(JKRhb): Refactor
    final action = thingDescription.actions[actionName];

    if (action == null) {
      throw StateError('ConsumedThing $title does not have action $actionName');
    }

    final clientAndForm = _getClientFor(action.forms,
        OperationType.invokeaction, _AffordanceType.action, options, action);

    final form = clientAndForm.form;
    final client = clientAndForm.client;
    final input = servient.contentSerdes
        .valueToContent(interactionInput, action.input, form.contentType);

    final content = await client.invokeResource(form, input);

    final response = form.response;
    if (response != null) {
      if (content.type != response.contentType) {
        throw UnexpectedReponseException('Unexpected type in response');
      }
    }

    return InteractionOutput(
        content, servient.contentSerdes, form, action.output);
  }

  @override
  Future<Subscription> observeProperty(
      String propertyName, scripting_api.InteractionListener listener,
      [scripting_api.ErrorListener? onError,
      InteractionOptions? options]) async {
    final property = thingDescription.properties[propertyName];

    if (property == null) {
      throw StateError(
          'ConsumedThing $title does not have property $propertyName');
    }

    if (_observedProperties.containsKey(propertyName)) {
      throw ArgumentError("ConsumedThing '$title' already has a function "
          "subscribed to $propertyName. You can only observe once");
    }

    return _createSubscription(property, options, listener, onError,
        propertyName, property, SubscriptionType.property);
  }

  Future<Subscription> _createSubscription(
    InteractionAffordance affordance,
    scripting_api.InteractionOptions? options,
    scripting_api.InteractionListener listener,
    scripting_api.ErrorListener? onError,
    String affordanceName,
    DataSchema? dataSchema,
    SubscriptionType subscriptionType,
  ) async {
    final OperationType operationType;
    final _AffordanceType affordanceType;
    final Map<String, Subscription> subscriptions;

    if (subscriptionType == SubscriptionType.property) {
      operationType = OperationType.observeproperty;
      affordanceType = _AffordanceType.property;
      subscriptions = _observedProperties;
    } else {
      operationType = OperationType.subscribeevent;
      affordanceType = _AffordanceType.event;
      subscriptions = _subscribedEvents;
    }

    final clientAndForm = _getClientFor(
        affordance.forms, operationType, affordanceType, options, affordance);

    final form = clientAndForm.form;
    final client = clientAndForm.client;

    final subscription = await client.subscribeResource(
      form,
      next: (content) => listener(
          InteractionOutput(content, servient.contentSerdes, form, dataSchema)),
      error: (error) {
        if (onError != null) {
          onError(error);
        }
      },
      complete: () => removeSubscription(affordanceName, subscriptionType),
    );
    if (subscriptionType == SubscriptionType.property) {
      _observedProperties[affordanceName] = subscription;
    } else {
      _subscribedEvents[affordanceName] = subscription;
    }

    subscriptions[affordanceName] = subscription;

    return subscription;
  }

  Future<PropertyReadMap> _readProperties(
      List<String> propertyNames, InteractionOptions? options) async {
    final Map<String, Future<InteractionOutput>> outputs = {};

    for (final propertyName in propertyNames) {
      outputs[propertyName] = readProperty(propertyName, options);
    }

    final outputList = await Future.wait(outputs.values);

    return Map.fromIterables(outputs.keys, outputList);
  }

  @override
  Future<PropertyReadMap> readAllProperties([InteractionOptions? options]) {
    final propertyNames =
        thingDescription.properties.keys.toList(growable: false);

    return _readProperties(propertyNames, options);
  }

  @override
  Future<PropertyReadMap> readMultipleProperties(List<String> propertyNames,
      [InteractionOptions? options]) {
    return _readProperties(propertyNames, options);
  }

  @override
  Future<Subscription> subscribeEvent(
      String eventName, scripting_api.InteractionListener listener,
      [scripting_api.ErrorListener? onError, InteractionOptions? options]) {
    // TODO(JKRhb): Handle subscription and cancellation data.
    final event = thingDescription.events[eventName];

    if (event == null) {
      throw StateError('ConsumedThing $title does not have event $eventName');
    }

    if (_subscribedEvents.containsKey(eventName)) {
      throw ArgumentError("ConsumedThing '$title' already has a function "
          "subscribed to $eventName. You can only subscribe once.");
    }

    return _createSubscription(event, options, listener, onError, eventName,
        event.data, SubscriptionType.event);
  }

  @override
  Future<void> writeMultipleProperties(PropertyWriteMap valueMap,
      [InteractionOptions? options]) async {
    await Future.wait(
        valueMap.keys.map((key) => writeProperty(key, valueMap[key])));
  }

  /// Removes a subscription with a specified [key] and [type].
  void removeSubscription(String key, SubscriptionType type) {
    switch (type) {
      case SubscriptionType.property:
        _observedProperties.remove(key);
        break;
      case SubscriptionType.event:
        _subscribedEvents.remove(key);
        break;
    }
  }

  static bool _supportsOperationType(
      Form form, _AffordanceType affordanceType, OperationType operationType) {
    List<String>? operationTypes = form.op;

    switch (affordanceType) {
      case _AffordanceType.property:
        operationTypes ??= [
          OperationType.readproperty.toShortString(),
          OperationType.writeproperty.toShortString()
        ];
        break;
      case _AffordanceType.action:
        operationTypes ??= [OperationType.invokeaction.toShortString()];
        break;
      case _AffordanceType.event:
        operationTypes ??= [
          OperationType.subscribeevent.toShortString(),
          OperationType.unsubscribeevent.toShortString()
        ];
        break;
    }

    return operationTypes.contains(operationType.toShortString());
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

/// Private class providing a tuple of a [ProtocolClient] and a [Form].
class _ClientAndForm {
  // TODO(JKRhb): Check if this class is actually needed
  final ProtocolClient client;
  final Form form;

  _ClientAndForm(this.client, this.form);
}
