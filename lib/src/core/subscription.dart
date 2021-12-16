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
import '../scripting_api/consumed_thing.dart';
import '../scripting_api/subscription.dart' as scripting_api;

/// Implementation of the [scripting_api.Subscription] interface.
class Subscription implements scripting_api.Subscription {
  @override
  Form? form;

  @override
  InteractionAffordance? interaction;

  @override
  String? name;

  @override
  ConsumedThing? thing;

  @override
  scripting_api.SubscriptionType? type;
}
