// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:typed_data";

import "package:coap/coap.dart";
import "package:meta/meta.dart";

/// Allows for configuring the behavior of CoAP clients and servers.
@immutable
class CoapConfig {
  /// Creates a new [CoapConfig] object.
  const CoapConfig({
    this.port = 5683,
    this.securePort = 5684,
    this.blocksize,
    this.allowMulticastDiscovery = false,
    this.multicastDiscoveryTimeout = const Duration(minutes: 60),
    this.dtlsCiphers,
    this.rootCertificates = const [],
    this.dtlsWithTrustedRoots = true,
    this.dtlsVerify = true,
    this.clientCertificate,
    this.clientPrivateKey,
    this.verifyPrivateKey = false,
    this.initTimeout,
  });

  final Duration? initTimeout;

  /// Whether certificates should be verified by OpenSSL.
  final bool dtlsVerify;

  /// Whether OpenSSL should be used with trusted Root Certificates.
  final bool dtlsWithTrustedRoots;

  /// Can be used to specify the Ciphers that should be used by OpenSSL.
  final String? dtlsCiphers;

  /// List of custom root certificates to use with OpenSSL.
  final List<Uint8List> rootCertificates;

  /// The port number used by a client or server. Defaults to 5683.
  final int port;

  /// The coaps port number used by a client or server. Defaults to 5684.
  final int securePort;

  /// The preferred block size for blockwise transfer.
  final int? blocksize;

  /// Indicates if multicast should be available for discovery.
  ///
  /// Defaults to false for security reasons, as multicast can lead to
  /// amplification scenarios/attacks (c.f., [WoT Discovery Specification]).
  ///
  /// [WoT Discovery Specification]: https://w3c.github.io/wot-discovery/#security-consideration-amp-ddos
  final bool allowMulticastDiscovery;

  /// The duration after which multicast discovery is supposed to time out.
  ///
  /// Defaults to 60 seconds.
  final Duration multicastDiscoveryTimeout;

  /// Name of a file referring to a client certificate used with DTLS PKI mode.
  final ClientCertificate? clientCertificate;

  /// Name of a file referring to a private client key used with DTLS PKI mode.
  final ClientPrivateKey? clientPrivateKey;

  /// Whether the private key of the client certificate should be verified when
  /// creating the DTLS context.
  final bool verifyPrivateKey;
}
