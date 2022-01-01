// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import '../../scripting_api.dart' as scripting_api;
import '../../scripting_api.dart'
    hide ConsumedThing, InteractionOutput, Subscription;
import '../definitions/form.dart';
import '../definitions/interaction_affordances/interaction_affordance.dart';
import '../definitions/security_scheme.dart';
import '../definitions/thing_description.dart';
import 'interaction_output.dart';
import 'operation_type.dart';
import 'protocol_interfaces/protocol_client.dart';
import 'servient.dart';
import 'subscription.dart';

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

  final List<String> _security = [];
  final Map<String, SecurityScheme> _securityDefinitions = {};

  /// Constructor
  ConsumedThing(this.servient, this.thingDescription)
      : title = thingDescription.title {
    _augmentInteractionAffordanceForms();
  }

  /// Checks if the [Servient] of this [ConsumedThing] supports a protocol
  /// [scheme].
  bool hasClientFor(String scheme) => servient.hasClientFor(scheme);

  _ClientAndForm _getClientFor(List<Form> forms, OperationType operationType,
      _AffordanceType affordanceType, InteractionOptions? options) {
    // TODO(JKRhb): This method is mostly taken from node-wot and has to be
    //              reworked.

    if (forms.isEmpty) {
      throw ArgumentError(
          'ConsumedThing "$title" has no links for this interaction');
    }

    ProtocolClient client;
    Form form;

    final int? formIndex = options?.formIndex;

    if (formIndex != null) {
      if (formIndex >= 0 && formIndex < forms.length) {
        form = forms[formIndex];
        final scheme = Uri.parse(form.href).scheme;
        client = servient.clientFor(scheme);
      } else {
        throw ArgumentError('ConsumedThing "$title" missing formIndex for '
            '$formIndex"');
      }
    } else {
      // ignore: unused_local_variable
      final schemes = forms.map((form) => Uri.parse(form.href).scheme);

      form =
          forms.firstWhere((form) => hasClientFor(Uri.parse(form.href).scheme));
      final scheme = Uri.parse(form.href).scheme;
      client = servient.clientFor(scheme);
    }

    _ensureClientSecurity(client, form);

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

  void _ensureClientSecurity(ProtocolClient client, Form form) {
    if (_securityDefinitions.isNotEmpty) {
      // TODO(JKRhb): This method is still a bit weird
      // FIXME: ID has to be properly determined
      final id = thingDescription.id ?? thingDescription.title;

      if (form.security != null) {
        client.setSecurity(
            _getSecuritySchemes(form.security), servient.credentials(id));
      } else if (_security.isNotEmpty) {
        client.setSecurity(
            _getSecuritySchemes(_security), servient.credentials(id));
      }
    }
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
        .map((form) => form.augment(thingDescription.base))
        .toList();
  }

  List<SecurityScheme> _getSecuritySchemes(List<String>? security) {
    if (security == null) {
      return List.empty();
    }

    return _securityDefinitions.entries
        .where((definition) => security.contains(definition.key))
        .map((definition) => definition.value)
        .toList();
  }

  @override
  Future<Subscription> observeProperty(
      String propertyName, scripting_api.InteractionListener listener,
      [scripting_api.ErrorListener? onError, InteractionOptions? options]) {
    // TODO(JKRhb): implement observeProperty
    throw UnimplementedError();
  }

  @override
  Future<PropertyReadMap> readAllProperties([InteractionOptions? options]) {
    // TODO(JKRhb): implement readAllProperties
    throw UnimplementedError();
  }

  @override
  Future<PropertyReadMap> readMultipleProperties(List<String> propertyNames,
      [InteractionOptions? options]) {
    // TODO(JKRhb): implement readMultipleProperties
    throw UnimplementedError();
  }

  @override
  Future<Subscription> subscribeEvent(
      String eventName, scripting_api.InteractionListener listener,
      [scripting_api.ErrorListener? onError, InteractionOptions? options]) {
    // TODO(JKRhb): implement subscribeEvent
    throw UnimplementedError();
  }

  @override
  Future<void> writeMultipleProperties(PropertyWriteMap valueMap,
      [InteractionOptions? options]) {
    // TODO(JKRhb): implement writeMultipleProperties
    throw UnimplementedError();
  }
}

/// Private class providing a tuple of a [ProtocolClient] and a [Form].
class _ClientAndForm {
  // TODO(JKRhb): Check if this class is actually needed
  final ProtocolClient client;
  final Form form;

  _ClientAndForm(this.client, this.form);
}
