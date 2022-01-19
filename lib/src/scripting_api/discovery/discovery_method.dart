// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

/// Enumeration of possible discovery methods.
///
/// See [WoT Scripting API Specification, Section 10.2][spec link].
///
/// [spec link]: https://w3c.github.io/wot-scripting-api/#the-discoverymethod-enumeration
// TODO(JKRhb): `any` and `multicast` have been removed in later versions. We
//              probably need to ask/discuss with the Scripting API Taskforce
//              how to deal with CoAP (multicast) discovery from CoRE Resource
//              Directories.
enum DiscoveryMethod {
  /// "Any" discovery (unspecified).
  any,

  /// Direct fetching of a Thing's Thing Description from the ThingFilter's url.
  direct,

  /// Discovery from a Directory specified by the ThingFilter's url.
  directory,

  /// Multicast discovery (unspecified).
  multicast,
}
