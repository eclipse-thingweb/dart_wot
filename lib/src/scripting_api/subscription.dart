// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../definitions/form.dart';
import '../definitions/interaction_affordances/interaction_affordance.dart';
import '../definitions/operation_type.dart';

/// [Exception] that is thrown when error during the unsubscribe process occurs.
class UnsubscribeException implements Exception {
  /// Constructor.
  UnsubscribeException(this._message);

  final String _message;

  @override
  String toString() => 'UnsubscribeException: $_message';
}

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
abstract interface class Subscription {
  /// Denotes whether the subsciption is active, i.e. it is not stopped because
  /// of an error or because of invocation of the [stop] method.
  bool get active;

  /// Stops delivering notifications for the subscription.
  ///
  /// This method accepts optional arguments as [interaction options]
  /// ([formIndex], [uriVariables], and [data]) and returns a [Future].
  ///
  /// [interaction options]: https://www.w3.org/TR/wot-scripting-api/#the-interactionoptions-dictionary
  Future<void> stop({
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  });
}

/// Finds a matching unsubscribe [Form] for a subscription [form].
///
/// Uses either a dedicated [formIndex] or determines the [Form] using
/// the [interaction] Affordance and the [type] of subscription it belongs to.
// TODO(JKRhb): Using an index does not seem the best idea to me.
Form findUnsubscribeForm(
  InteractionAffordance interaction,
  SubscriptionType type,
  Form form,
  int? formIndex,
) {
  if (formIndex != null) {
    return interaction.forms[formIndex];
  }

  final operationType = type.operationType;
  final formOperations = form.op;

  // The default op value also contains the unsubscribe/unobserve operation.
  if (formOperations.contains(operationType)) {
    return form;
  }

  final unsubscribeForm = _findFormByScoring(interaction, form, operationType);

  if (unsubscribeForm == null) {
    throw UnsubscribeException('Could not find matching form for unsubscribe');
  }

  return unsubscribeForm;
}

Form? _findFormByScoring(
  InteractionAffordance interaction,
  Form form,
  OperationType operationType,
) {
  int maxScore = 0;
  Form? foundForm;

  for (final Form currentForm in interaction.forms) {
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
