// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import '../../definitions.dart';
import '../../scripting_api.dart' as scripting_api;

/// Implemention of the [scripting_api.ThingDiscovery] interface.
class ThingDiscovery implements scripting_api.ThingDiscovery {
  @override
  bool active = false;

  @override
  bool done = false;

  @override
  Exception? error;

  @override
  scripting_api.ThingFilter? thingFilter;

  /// Creates a new [ThingDiscovery] object with a given [thingFilter].
  ThingDiscovery(this.thingFilter);

  @override
  Future<ThingDescription> next() {
    // TODO(JKRhb): implement next
    throw UnimplementedError();
  }

  @override
  void start() {
    // TODO(JKRhb): implement start
  }

  @override
  void stop() {
    // TODO(JKRhb): implement stop
  }
}
