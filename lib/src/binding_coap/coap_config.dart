// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

/// Allows for configuring the behavior of CoAP clients and servers.
class CoapConfig {
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

  /// Creates a new [CoapConfig] object.
  CoapConfig({
    this.port = 5683,
    this.securePort = 5684,
    this.blocksize,
    this.useTinyDtls = false,
    this.useOpenSsl = false,
  });
}
