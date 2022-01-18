// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

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

  /// Discovers [ThingDescription]s, which are passed to a [callback] function
  /// upon retrieval.
  /// As this part of the Scripting API specification is still in development,
  /// this method's implementation is in an experimental state and does not
  /// conform to the specification's latest version.
  ///
  /// An optional [thingFilter] can be passed for filtering out TDs before they
  /// are processed. The [thingFilter] also contains relevant information for
  /// controlling the Discovery process, e. g. a URL, the discovery method
  /// (`direct` or `directory`), and a "fragement" [Map] for filtering out
  /// properties of a [ThingDescription].
  ///
  /// So far, however, only `direct` discovery is supported. Therefore, despite
  /// its method signature, a compatible [ThingFilter] with a defined URL is
  /// required. Otherwise, an [ArgumentError] will be thrown.
  ///
  /// The [ThingDiscovery] object that is returned by this function can be used
  /// for stopping the Discovery process and retrieving information about its
  /// current state (i. e. whether it is still `active` or already `done`).
  ThingDiscovery discover(DiscoveryListener callback,
      [ThingFilter? thingFilter]);
}
