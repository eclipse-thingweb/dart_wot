// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

/// Contains the constraints for discovering Things as key-value pairs.
///
/// See [WoT Scripting API Specification, Section 10.3][spec link].
///
/// [spec link]: https://w3c.github.io/wot-scripting-api/#the-thingfilter-dictionary
class ThingFilter {
  /// Constructor.
  ThingFilter(this.fragment);

  /// Represents a template object used for matching property by property
  /// against discovered Things.
  Map<String, dynamic> fragment;
}
