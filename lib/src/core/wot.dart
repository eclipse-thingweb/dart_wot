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
import '../definitions/thing_description.dart';
import 'consumed_thing.dart';
import 'exposed_thing.dart';
import 'servient.dart';
import 'thing_discovery.dart' show ThingDiscovery;

/// Implementation of the [scripting_api.WoT] runtime interface.
class WoT implements scripting_api.WoT {
  final Servient _servient;

  /// Creates a new [WoT] runtime based on a [Servient].
  WoT(this._servient);

  /// Consumes a [ThingDescription] and returns a [ConsumedThing].
  ///
  /// The returned [ConsumedThing] can then be used to trigger
  /// interaction affordances exposed by the Thing.
  @override
  Future<ConsumedThing> consume(ThingDescription thingDescription) async {
    return ConsumedThing(_servient, thingDescription);
  }

  /// Exposes a Thing based on a (partial) TD.
  @override
  Future<ExposedThing> produce(Map<String, dynamic> init) async {
    final newThing = ExposedThing(_servient, init);
    if (_servient.addThing(newThing)) {
      return newThing;
    } else {
      throw StateError('Thing already exists: ${newThing.title}');
    }
  }

  /// Discovers [ThingDescription]s matching a given [filter].
  @override
  ThingDiscovery discover(scripting_api.DiscoveryListener callback,
      [scripting_api.ThingFilter? filter]) {
    return ThingDiscovery(callback, filter, _servient)..start();
  }
}
