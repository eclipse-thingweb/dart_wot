// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../../scripting_api.dart' as scripting_api;
import '../../scripting_api.dart' hide ConsumedThing, InteractionOutput;
import '../definitions/credentials/apikey_credentials.dart';
import '../definitions/credentials/basic_credentials.dart';
import '../definitions/credentials/credentials.dart';
import '../definitions/credentials/digest_credentials.dart';
import '../definitions/credentials/psk_credentials.dart';
import '../definitions/data_schema.dart';
import '../definitions/form.dart';
import '../definitions/interaction_affordances/interaction_affordance.dart';
import '../definitions/security/apikey_security_scheme.dart';
import '../definitions/security/basic_security_scheme.dart';
import '../definitions/security/digest_security_scheme.dart';
import '../definitions/security/psk_security_scheme.dart';
import '../definitions/security/security_scheme.dart';
import '../definitions/thing_description.dart';
import 'interaction_output.dart';
import 'operation_type.dart';
import 'protocol_interfaces/protocol_client.dart';
import 'servient.dart';

enum _AffordanceType {
  action,
  property,
  // ignore: unused_field
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

  /// Constructor
  ConsumedThing(this.servient, this.thingDescription)
      : title = thingDescription.title {
    _augmentInteractionAffordanceForms();
  }

  /// Checks if the [Servient] of this [ConsumedThing] supports a protocol
  /// [scheme].
  bool hasClientFor(String scheme) => servient.hasClientFor(scheme);

  static void _applyCredentials(Map<String, Credentials>? credentialStore,
      Map<String, SecurityScheme> securityDefinitions) {
    for (final entry in securityDefinitions.entries) {
      final credentials = credentialStore?[entry.key];
      final securityDefinition = entry.value;
      // TODO(JKRhb): Maybe this matching can be done more elegantly.
      if (securityDefinition is BasicSecurityScheme &&
          credentials is BasicCredentials) {
        securityDefinition.credentials = credentials;
      } else if (securityDefinition is PskSecurityScheme &&
          credentials is PskCredentials) {
        securityDefinition.credentials = credentials;
      } else if (securityDefinition is DigestSecurityScheme &&
          credentials is DigestCredentials) {
        securityDefinition.credentials = credentials;
      } else if (securityDefinition is ApiKeySecurityScheme &&
          credentials is ApiKeyCredentials) {
        securityDefinition.credentials = credentials;
      }
    }
  }

  _ClientAndForm _getClientFor(List<Form> forms, OperationType operationType,
      _AffordanceType affordanceType, InteractionOptions? options) {
    // TODO(JKRhb): This method is mostly taken from node-wot and has to be
    //              reworked.

    if (forms.isEmpty) {
      throw ArgumentError(
          'ConsumedThing "$title" has no links for this interaction');
    }

    ProtocolClient client;
    Form foundForm;

    final int? formIndex = options?.formIndex;

    // FIXME: ID has to be properly determined
    final id = thingDescription.id ?? thingDescription.title;

    final credentials = servient.credentials(id);

    _applyCredentials(credentials, thingDescription.securityDefinitions);

    if (formIndex != null) {
      if (formIndex >= 0 && formIndex < forms.length) {
        foundForm = forms[formIndex];
        final scheme = Uri.parse(foundForm.href).scheme;
        client = servient.clientFor(scheme);
      } else {
        throw ArgumentError('ConsumedThing "$title" missing formIndex for '
            '$formIndex"');
      }
    } else {
      foundForm = forms.firstWhere((form) =>
          hasClientFor(Uri.parse(form.href).scheme) &&
          _supportsOperationType(form, affordanceType, operationType));
      final scheme = Uri.parse(foundForm.href).scheme;
      client = servient.clientFor(scheme);
    }

    return _ClientAndForm(client, foundForm);
  }

  @override
  Future<InteractionOutput> readProperty(String propertyName,
      [InteractionOptions? options]) async {
    final property = thingDescription.properties[propertyName];

    if (property == null) {
      throw StateError(
          'ConsumedThing $title does not have property $propertyName');
    }

    final clientAndForm = _getClientFor(property.augmentedForms,
        OperationType.readproperty, _AffordanceType.property, options);

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

    final clientAndForm = _getClientFor(property.augmentedForms,
        OperationType.writeproperty, _AffordanceType.property, options);

    final form = clientAndForm.form; // TODO(JKRhb): Handle URI variables
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

    final clientAndForm = _getClientFor(action.augmentedForms,
        OperationType.invokeaction, _AffordanceType.action, options);

    final form = clientAndForm.form; // TODO(JKRhb): Handle URI variables
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

  void _augmentInteractionAffordanceForms() {
    final interactionAffordanceList = [
      thingDescription.properties,
      thingDescription.actions,
      thingDescription.events
    ];

    interactionAffordanceList.expand((e) => e.values).forEach(_augmentForms);
  }

  void _augmentForms(InteractionAffordance interactionAffordance) {
    interactionAffordance.augmentedForms = interactionAffordance.forms
        .map((form) => form.augment(thingDescription))
        .toList();
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
    OperationType operationType;
    _AffordanceType affordanceType;
    if (subscriptionType == SubscriptionType.property) {
      operationType = OperationType.observeproperty;
      affordanceType = _AffordanceType.property;
    } else {
      operationType = OperationType.subscribeevent;
      affordanceType = _AffordanceType.event;
    }

    final clientAndForm = _getClientFor(
        affordance.augmentedForms, operationType, affordanceType, options);

    final form = clientAndForm.form; // TODO(JKRhb): Handle URI variables
    final client = clientAndForm.client;

    final subscription = await client.subscribeResource(
        form, () => removeSubscription(affordanceName, subscriptionType),
        (content) {
      try {
        listener(InteractionOutput(
            content, servient.contentSerdes, form, dataSchema));
      } on Exception {
        // Exception is handled by onError function. Not sure if this is the
        // best design, though.
        // TODO(JKRhb): Check if this try-catch-block can be removed.
      }
    }, (error) {
      if (onError != null) {
        onError(error);
      }
    }, () {
      // TODO(JKRhb): current scripting api cannot handle this (apparently)
    });

    if (subscriptionType == SubscriptionType.property) {
      _observedProperties[affordanceName] = subscription;
    } else {
      _subscribedEvents[affordanceName] = subscription;
    }

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
    final propertyNames = thingDescription.properties.keys.toList();

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

    // TODO(JKRhb): Replace with constants or stringified OperationType enum
    //              values.
    switch (affordanceType) {
      case _AffordanceType.property:
        operationTypes ??= ["readproperty", "writeproperty"];
        break;
      case _AffordanceType.action:
        operationTypes ??= ["invokeaction"];
        break;
      case _AffordanceType.event:
        operationTypes ??= ["subscribeevent", "unsubscribeevent"];
        break;
    }

    return operationTypes.contains(operationType.toShortString());
  }
}

/// Private class providing a tuple of a [ProtocolClient] and a [Form].
class _ClientAndForm {
  // TODO(JKRhb): Check if this class is actually needed
  final ProtocolClient client;
  final Form form;

  _ClientAndForm(this.client, this.form);
}
