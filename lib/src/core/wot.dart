// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../../scripting_api.dart' as scripting_api;
import '../definitions/thing_description.dart';
import '../scripting_api/discovery/discovery_method.dart';
import 'consumed_thing.dart';
import 'exposed_thing.dart';
import 'servient.dart';
import 'thing_discovery.dart' show ThingDiscovery;

/// This [Exception] is thrown if an error during the consumption of a
/// [ThingDescription] occurs.
class ThingConsumptionException implements Exception {
  /// Constructor
  ThingConsumptionException(this.identifier);

  /// The identifier of the [ThingDescription] that triggered this [Exception].
  final String identifier;

  @override
  String toString() {
    return 'ThingConsumptionException: A ConsumedThing with identifier '
        '$identifier already exists.';
  }
}

/// This [Exception] is thrown if an error during the production of a
/// [ThingDescription] occurs.
class ThingProductionException implements Exception {
  /// Constructor
  ThingProductionException(this.identifier);

  /// The identifier of the [ThingDescription] that triggered this [Exception].
  final String identifier;

  @override
  String toString() {
    return 'ThingProductionException: An ExposedThing with identifier '
        '$identifier already exists.';
  }
}

/// Implementation of the [scripting_api.WoT] runtime interface.
class WoT implements scripting_api.WoT {
  /// Creates a new [WoT] runtime based on a [Servient].
  WoT(this._servient);

  final Servient _servient;

  /// Consumes a [ThingDescription] and returns a [scripting_api.ConsumedThing].
  ///
  /// The returned [ConsumedThing] can then be used to trigger
  /// interaction affordances exposed by the Thing.
  ///
  /// If a [ThingDescription] with the same identifier has already been
  @override
  Future<scripting_api.ConsumedThing> consume(
    ThingDescription thingDescription,
  ) async {
    final newThing = ConsumedThing(_servient, thingDescription);
    if (_servient.addConsumedThing(newThing)) {
      return newThing;
    } else {
      final id = thingDescription.identifier;
      throw ThingConsumptionException(id);
    }
  }

  /// Exposes a Thing based on a (partial) TD.
  @override
  Future<scripting_api.ExposedThing> produce(Map<String, dynamic> init) async {
    final newThing = ExposedThing(_servient, init);
    if (_servient.addThing(newThing)) {
      return newThing;
    } else {
      final id = newThing.thingDescription.identifier;
      throw ThingProductionException(id);
    }
  }

  @override
  ThingDiscovery discover(
    Uri url, {
    scripting_api.ThingFilter? thingFilter,
    DiscoveryMethod method = DiscoveryMethod.direct,
  }) {
    return ThingDiscovery(url, thingFilter, _servient, method: method);
  }
}
