// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../definitions/thing_description.dart';
import 'consumed_thing.dart';
import 'discovery/discovery_method.dart';
import 'discovery/thing_discovery.dart';
import 'discovery/thing_filter.dart';
import 'exposed_thing.dart';
import 'types.dart';

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
  /// based on the underlying impementation.
  Future<ExposedThing> produce(ExposedThingInit exposedThingInit);

  /// Requests a [ThingDescription] from the given [url].
  Future<ThingDescription> requestThingDescription(Uri url);

  /// Discovers [ThingDescription]s from a given [url] using the specified
  /// [method].
  ///
  /// As this part of the Scripting API specification is still in development,
  /// this method's implementation is in an experimental state and does not
  /// conform to the specification's latest version.
  ///
  /// A [thingFilter] may be passed for filtering out TDs before they
  /// are processed.
  /// However, since the semantics of the [ThingFilter] are not well-defined in
  /// the Scripting API document, this parameter does not have an effect yet.
  ///
  /// The [ThingDiscovery] object that is returned by this function implements
  /// the  [Stream] interface, which makes it possible to `listen` for
  /// discovered [ThingDescription]s or to iterate over the discovered results
  /// using the `await for` syntax.
  /// It also allows for stopping the Discovery process prematurely and
  /// for retrieving information about its current state (i.e., whether it is
  /// still `active`).
  ThingDiscovery discover(
    Uri url, {
    ThingFilter? thingFilter,
    DiscoveryMethod method = DiscoveryMethod.direct,
  });
}
