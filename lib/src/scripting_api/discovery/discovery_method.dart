// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

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
