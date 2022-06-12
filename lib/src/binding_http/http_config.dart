// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

/// Allows for configuring the behavior of HTTP clients and servers.
class HttpConfig {
  /// Creates a new [HttpConfig] object.
  HttpConfig({this.port, this.secure});

  /// Custom port number that should be used by a server.
  ///
  /// Defaults to 80 for HTTP and 443 for HTTPS.
  int? port;

  /// Indicates if the client or server should use HTTPS.
  bool? secure;
}
