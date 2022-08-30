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
  /// Direct fetching of a Thing's Thing Description from the ThingFilter's url.
  direct,

  /// Discovery from a Thing Description Direcotry (TDD) specified by the
  /// ThingFilter's url.
  ///
  /// The URL should point to the `/things` endpoint of a Thing Description
  /// Directory.
  ///
  /// Note: This discovery method is not properly specified in the Scripting
  /// API specification yet. Therefore, its implementation will probably change
  /// in future versions.
  directory,

  /// Discovery using the core link format ([RFC 6690]).
  ///
  /// Note: This discovery method is not officially supported by the Scripting
  /// API specification (yet).
  ///
  /// [RFC 6690]: https://datatracker.ietf.org/doc/html/rfc6690
  coreLinkFormat,

  /// Discovery from a CoRE Resource Directory ([RFC 9176]).
  ///
  /// Note: This discovery method is not officially supported by the Scripting
  /// API specification (yet).
  ///
  /// [RFC 9176]: https://datatracker.ietf.org/doc/html/rfc9176
  coreResourceDirectory,

  /// Discovery using DNS-Based Service Discovery (DNS-SD, [RFC 6763].
  ///
  /// Currently, only Multicast DNS (mDNS, [RFC 6762]) for discovery on the same
  /// network is supported.
  /// Futhermore, discovery using this method currently does not work on Windows
  /// due to limitations in the `multicast_dns` package.
  ///
  /// [RFC 6762]: https://www.rfc-editor.org/rfc/rfc6762
  /// [RFC 6763]: https://www.rfc-editor.org/rfc/rfc6763
  dnsServiceDiscovery,
}
