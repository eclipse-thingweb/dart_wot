// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:meta/meta.dart";

import "../definitions.dart";

import "consumed_thing.dart";
import "discovery/directory_payload_format.dart";
import "discovery/discovery_configuration.dart";
import "discovery/thing_discovery.dart";
import "discovery/thing_filter.dart";
import "exposed_thing.dart";
import "types.dart";

/// Interface for a [WoT] runtime.
///
/// See WoT Scripting API specification,
/// [section 5](https://w3c.github.io/wot-scripting-api/#the-wot-namespace)
abstract interface class WoT {
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
  /// based on the underlying implementation.
  Future<ExposedThing> produce(ExposedThingInit exposedThingInit);

  /// Requests a [ThingDescription] from the given [url].
  Future<ThingDescription> requestThingDescription(Uri url);

  /// Starts the discovery process that given a TD Directory [url], will provide
  /// [ThingDescription] objects for Thing Descriptions that match an optional
  /// [filter] argument of type [ThingFilter].
  Future<ThingDiscoveryProcess> exploreDirectory(
    Uri url, {
    ThingFilter? filter,
    int? offset,
    int? limit,
    DirectoryPayloadFormat? format,
  });

  /// Discovers [ThingDescription]s based on the provided
  /// [discoveryConfigurations].
  ///
  /// A [thingFilter] may be passed for filtering out TDs before they
  /// are processed.
  /// However, since the semantics of the [ThingFilter] are not well-defined in
  /// the Scripting API document, this parameter does not have an effect yet.
  ///
  /// The [ThingDiscovery] object that is returned by this function implements
  /// the [Stream] interface, which makes it possible to `listen` for
  /// discovered [ThingDescription]s or to iterate over the discovered results
  /// using the `await for` syntax.
  /// It also allows for stopping the Discovery process prematurely and
  /// for retrieving information about its current state (i.e., whether it is
  /// still [ThingDiscovery.active]).
  ///
  /// The shape of the `discover` API is still experimental and will most likely
  /// change in the future.
  ThingDiscovery discover(
    @experimental List<DiscoveryConfiguration> discoveryConfigurations, {
    ThingFilter? thingFilter,
  });
}
