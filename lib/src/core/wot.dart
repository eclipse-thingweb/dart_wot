// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

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
  ThingDiscovery discover([scripting_api.ThingFilter? filter]) {
    // TODO(JKRhb): Decide if the user should call the start method.
    return ThingDiscovery(filter, _servient)..start();
  }
}
