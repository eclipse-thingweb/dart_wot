// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import 'discovery_method.dart';

/// Contains the constraints for discovering Things as key-value pairs.
///
/// See [WoT Scripting API Specification, Section 10.3][spec link].
///
/// [spec link]: https://w3c.github.io/wot-scripting-api/#the-thingfilter-dictionary
// TODO(JKRhb): This part of the specification has to be improved IMHO.
abstract class ThingFilter {
  /// Represents the discovery type that should be used in the discovery process
  DiscoveryMethod method = DiscoveryMethod.directory;

  /// Represents the URL of the target entity serving the discovery request.
  ///
  /// This is, for instance the URL of a Thing Directory (if method is
  /// "directory"), or the URL of a directly targeted Thing (if method is
  /// "direct").
  String? url;

  /// Represents a template object used for matching property by property
  /// against discovered Things.
  Map<String, dynamic>? fragment;
}
