// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

/// Allows for configuring the behavior of CoAP clients and servers.
class CoapConfig {
  /// Creates a new [CoapConfig] object.
  CoapConfig({
    this.port = 5683,
    this.securePort = 5684,
    this.blocksize,
    this.useTinyDtls = false,
    this.useOpenSsl = false,
    this.allowMulticastDiscovery = false,
    this.multicastDiscoveryTimeout = const Duration(minutes: 60),
  });

  /// The port number used by a client or server. Defaults to 5683.
  final int port;

  /// The coaps port number used by a client or server. Defaults to 5684.
  final int securePort;

  /// The preferred block size for blockwise transfer.
  final int? blocksize;

  /// Indicates if tinydtls is available as a DTLS backend.
  final bool useTinyDtls;

  /// Indicates if openSSL is available as a DTLS backend.
  final bool useOpenSsl;

  /// Indicates if multicast should be available for discovery.
  ///
  /// Defaults to false for security reasons, as multicast can lead to
  /// amplication scenarios/attacks (c.f., [WoT Discovery Specification]).
  ///
  /// [WoT Discovery Specification]: https://w3c.github.io/wot-discovery/#security-consideration-amp-ddos
  final bool allowMulticastDiscovery;

  /// The duration after which multicast discovery is supposed to time out.
  ///
  /// Defaults to 60 seconds.
  final Duration multicastDiscoveryTimeout;
}
