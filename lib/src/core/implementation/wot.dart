// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:async";

import "package:meta/meta.dart";

import "../definitions.dart";
import "../scripting_api.dart" as scripting_api;
import "consumed_thing.dart";
import "servient.dart";
import "thing_discovery.dart";

/// Implementation of the [scripting_api.WoT] runtime interface.
class WoT implements scripting_api.WoT {
  /// Creates a new [WoT] runtime based on a [Servient].
  WoT(this._servient);

  final InternalServient _servient;

  /// Consumes a [ThingDescription] and returns a [scripting_api.ConsumedThing].
  ///
  /// The returned [ConsumedThing] can then be used to trigger
  /// interaction affordances exposed by the Thing.
  ///
  /// If a [ThingDescription] with the same identifier has already been
  @override
  Future<scripting_api.ConsumedThing> consume(
    ThingDescription thingDescription,
  ) =>
      _servient.consume(thingDescription);

  /// Exposes a Thing based on a (partial) TD.
  @override
  Future<scripting_api.ExposedThing> produce(
    Map<String, dynamic> init,
  ) =>
      _servient.produce(init);

  @override
  ThingDiscovery discover(
    @experimental
    List<scripting_api.DiscoveryConfiguration> discoveryConfigurations, {
    scripting_api.ThingFilter? thingFilter,
  }) =>
      _servient.discover(
        discoveryConfigurations,
        thingFilter: thingFilter,
      );

  @override
  Future<ThingDescription> requestThingDescription(Uri url) =>
      _servient.requestThingDescription(url);

  @override
  Future<scripting_api.ThingDiscoveryProcess> exploreDirectory(
    Uri url, {
    scripting_api.ThingFilter? filter,
    int? offset,
    int? limit,
    scripting_api.DirectoryPayloadFormat? format,
  }) =>
      _servient.exploreDirectory(
        url,
        thingFilter: filter,
        offset: offset,
        limit: limit,
        format: format,
      );
}
