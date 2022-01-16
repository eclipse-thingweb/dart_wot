// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import '../definitions/form.dart';
import '../definitions/interaction_affordances/interaction_affordance.dart';
import 'interaction_options.dart';

/// Indicates the type of the subscription.
enum SubscriptionType {
  /// The subscription is the observation of a property.
  property,

  /// The subscription is for an Event.
  event,
}

/// Represents a subscription to Property change and Event interactions.
abstract class Subscription {
  /// Denotes whether the subsciption is active, i.e. it is not stopped because
  /// of an error or because of invocation of the [stop] method.
  bool get active;

  /// Stops delivering notifications for the subscription.
  /// It takes an optional parameter [options] and returns a [Future].
  Future<void> stop([InteractionOptions? options]);
}

/// Finds a matching unsubscribe [Form] for a subscription [form].
///
/// Uses either a dedicated [formIndex] or determines the [Form] using
/// the [interaction] Affordance and the [type] of subscription it belongs to.
// TODO(JKRhb): Using an index does not seem the best idea to me.
Form findUnsubscribeForm(InteractionAffordance interaction,
    SubscriptionType type, Form form, int? formIndex) {
  if (formIndex != null) {
    interaction.forms[formIndex];
  }

  final operationType = _determineOpType(type);
  final formOperations = form.op;

  // The default op value also contains the unsubscribe/unobserve operation.
  if (formOperations == null || formOperations.contains(operationType)) {
    return form;
  }

  final unsubscribeForm = _findFormByScoring(interaction, form, operationType);

  if (unsubscribeForm == null) {
    // TODO(JKRhb): Add appropriate Exception type.
    throw Exception("Could not find matching form for unsubscribe");
  }

  return unsubscribeForm;
}

String _determineOpType(SubscriptionType? subscriptionType) {
  switch (subscriptionType) {
    case SubscriptionType.event:
      return "unsubscribeevent";
    case SubscriptionType.property:
      return "unobserveproperty";
    default:
      throw Exception();
  }
}

Form? _findFormByScoring(
    InteractionAffordance interaction, Form form, String operationType) {
  int maxScore = 0;
  Form? foundForm;

  for (Form currentForm in interaction.augmentedForms) {
    int score;
    if (form.op!.contains(operationType)) {
      score = 1;
    } else {
      continue;
    }

    if (Uri.parse(form.href).origin == Uri.parse(currentForm.href).origin) {
      score++;
    }

  /// The Thing Description fragment that describes the WoT [interaction].
  InteractionAffordance? interaction;

  /// The [Form] associated with this [Subscription].
  Form? form;

  /// The [ConsumedThing] associated with this [Subscription].
  ConsumedThing? thing;
}
