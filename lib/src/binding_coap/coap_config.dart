// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

/// Allows for configuring the behavior of CoAP clients and servers.
class CoapConfig {
  /// The port number used by a client or server. Defaults to 5683.
  int port;

  /// The preferred block size for blockwise transfer.
  int? blocksize;

  /// Creates a new [CoapConfig] object.
  CoapConfig({this.port = 5683, this.blocksize});
}
