// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "../definitions.dart";

/// [Exception] that is thrown when error during the unsubscribe process occurs.
class UnsubscribeException implements Exception {
  /// Constructor.
  UnsubscribeException(this._message);

  final String _message;

  @override
  String toString() => "UnsubscribeException: $_message";
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
