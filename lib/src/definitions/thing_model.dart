// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

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
