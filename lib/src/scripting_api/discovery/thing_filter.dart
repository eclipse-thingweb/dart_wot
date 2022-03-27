// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'discovery_method.dart';

/// Contains the constraints for discovering Things as key-value pairs.
///
/// See [WoT Scripting API Specification, Section 10.3][spec link].
///
/// [spec link]: https://w3c.github.io/wot-scripting-api/#the-thingfilter-dictionary
// TODO(JKRhb): This part of the specification has to be improved IMHO.
class ThingFilter {
  /// Represents the discovery type that should be used in the discovery process
  DiscoveryMethod method;

  /// Represents the URL of the target entity serving the discovery request.
  ///
  /// This is, for instance the URL of a Thing Directory (if method is
  /// "directory"), or the URL of a directly targeted Thing (if method is
  /// "direct").
  String? url;

  /// Represents a template object used for matching property by property
  /// against discovered Things.
  Map<String, dynamic>? fragment;

  /// Constructor.
  ThingFilter(
      {this.url, this.method = DiscoveryMethod.directory, this.fragment});
}
