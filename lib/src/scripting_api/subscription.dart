// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../definitions/form.dart';
import '../definitions/interaction_affordances/interaction_affordance.dart';
import '../definitions/operation_type.dart';
import 'interaction_options.dart';

/// Indicates the type of the subscription.
enum SubscriptionType {
  /// The subscription is the observation of a property.
  property,

  /// The subscription is for an Event.
  event;

  /// Gets the corresponding [OperationType] for this [SubscriptionType].
  OperationType get operationType {
    switch (this) {
      case SubscriptionType.property:
        return OperationType.observeproperty;
      case SubscriptionType.event:
        return OperationType.subscribeevent;
    }
  }
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

  final operationType = type.operationType;
  final formOperations = form.op;

  // The default op value also contains the unsubscribe/unobserve operation.
  if (formOperations.contains(operationType)) {
    return form;
  }

  final unsubscribeForm = _findFormByScoring(interaction, form, operationType);

  if (unsubscribeForm == null) {
    throw StateError("Could not find matching form for unsubscribe");
  }

  return unsubscribeForm;
}

Form? _findFormByScoring(
    InteractionAffordance interaction, Form form, OperationType operationType) {
  int maxScore = 0;
  Form? foundForm;

  for (Form currentForm in interaction.forms) {
    int score;
    if (form.op.contains(operationType)) {
      score = 1;
    } else {
      continue;
    }

    if (form.resolvedHref.origin == currentForm.resolvedHref.origin) {
      score++;
    }

    if (form.contentType == currentForm.contentType) {
      score++;
    }

    if (score > maxScore) {
      maxScore = score;
      foundForm = currentForm;
    }
  }

  return foundForm;
}
