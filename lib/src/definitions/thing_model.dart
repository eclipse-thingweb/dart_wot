// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import 'thing_description.dart';

/// Class representing a WoT Thing Model.
///
/// See W3C WoT Thing Description Specificition, [section 10][spec link].
///
/// [spec link]: https://w3c.github.io/wot-thing-description/#thing-model
class ThingModel {
  /// Converts this [ThingModel] to a [ThingDescription].
  ThingDescription toThingDescription() {
    return ThingDescription.fromThingModel(this);
  }
}
