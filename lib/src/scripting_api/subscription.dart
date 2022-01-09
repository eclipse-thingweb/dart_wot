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
import 'consumed_thing.dart';

/// Indicates the type of the subscription.
enum SubscriptionType {
  /// The subscription is the observation of a property.
  property,

  /// The subscription is for an Event.
  event,
}

/// Represents a subscription to Property change and Event interactions.
abstract class Subscription {
  /// Indicates what WoT Interaction this [Subscription] refers to.
  SubscriptionType? type;

  /// The Property or Event name.
  String? name;

  /// The Thing Description fragment that describes the WoT [interaction].
  InteractionAffordance? interaction;

  /// The [Form] associated with this [Subscription].
  Form? form;

  /// The [ConsumedThing] associated with this [Subscription].
  ConsumedThing? thing;
}
