// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import '../../definitions/thing_description.dart';
import 'thing_filter.dart';

/// Interface
abstract class ThingDiscovery {
  /// The [thingFilter] that is applied during the discovery process.
  ThingFilter? get thingFilter;

  /// Indicates if this [ThingDiscovery] object is active.
  bool get active;

  /// Indicates if this [ThingDiscovery] object is done.
  bool get done;

  /// The [Exception] that is thrown when an error occurs.
  Exception? get error;

  /// Starts the discovery process.
  void start();

  /// Stops the discovery process.
  void stop();

  /// Returns the next discovered [ThingDescription].
  Future<ThingDescription> next();
}
