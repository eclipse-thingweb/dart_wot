// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:io";

/// Allows for configuring the behavior of HTTP clients and servers.
class HttpConfig {
  /// Creates a new [HttpConfig] object.
  HttpConfig({
    int? port,
    this.secure = false,
    InternetAddress? bindAddress,
  })  : port = port ?? (secure ? 443 : 80),
        bindAddress = bindAddress ?? InternetAddress.anyIPv4;

  /// Custom port number that should be used by a server.
  ///
  /// Defaults to 80 for HTTP and 443 for HTTPS.
  final int port;

  /// Indicates if the client or server should use HTTPS.
  bool secure;

  /// The IP address the HTTP server should bind to.
  ///
  /// Defaults to [InternetAddress.anyIPv4].
  final InternetAddress bindAddress;
}
