// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../../definitions/thing_description.dart';
import 'thing_filter.dart';

/// Provides the properties and methods controlling the discovery process.
///
/// Note: This interface definition does not conform to the current Scripting
///       API specification, which is still a Work-in-Progress when it comes
///       to discovery.
abstract interface class ThingDiscovery implements Stream<ThingDescription> {
  /// The [thingFilter] that is applied during the discovery process.
  ThingFilter? get thingFilter;

  /// Indicates if this [ThingDiscovery] object is active.
  bool get active;

  /// Stops the discovery process.
  void stop();
}
