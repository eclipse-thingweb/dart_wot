// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import '../definitions/thing_description.dart';
import 'consumed_thing.dart';
import 'discovery/thing_discovery.dart';
import 'discovery/thing_filter.dart';
import 'exposed_thing.dart';
import 'types.dart';

/// Interface for a [WoT] runtime.
///
/// See WoT Scripting API specification,
/// [section 5](https://w3c.github.io/wot-scripting-api/#the-wot-namespace)
abstract class WoT {
  /// Asynchronously creates a [ConsumedThing] from a [thingDescription].
  ///
  /// This [ConsumedThing] can then be used to perform interactions with the
  /// Thing the [thingDescription] represents.
  Future<ConsumedThing> consume(ThingDescription thingDescription);

  /// Asynchronously produces an [ExposedThing] from an [exposedThingInit].
  ///
  /// The [exposedThingInit] is a Thing Description which does not have to
  /// include all fields that are usually required for a TD.
  /// Missing information is added during the production of the [ExposedThing],
  /// based on the underlying impementation.
  Future<ExposedThing> produce(ExposedThingInit exposedThingInit);

  /// Discovers Thing Descriptions and filters them based on an option
  /// [thingFilter].
  ///
  /// Returns a [ThingDiscovery] object which can be iterated for obtaining the
  /// Thing Descriptions that have been discovered.
  ThingDiscovery discover([ThingFilter? thingFilter]);
}
