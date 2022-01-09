// Copyright 2022 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

/// Allows for configuring the behavior of HTTP clients and servers.
class HttpConfig {
  /// Custom port number that should be used by a server.
  ///
  /// Defaults to 80 for HTTP and 443 for HTTPS.
  int? port;

  /// Indicates if the client or server should use HTTPS.
  bool? secure;

  /// Creates a new [HttpConfig] object.
  HttpConfig({this.port, this.secure});
}
