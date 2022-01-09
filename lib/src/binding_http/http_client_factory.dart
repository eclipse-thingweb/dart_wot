// Copyright 2022 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import '../core/protocol_interfaces/protocol_client.dart';
import '../core/protocol_interfaces/protocol_client_factory.dart';
import 'http_client.dart';
import 'http_config.dart';

/// A [ProtocolClientFactory] that produces HTTP clients.
class HttpClientFactory extends ProtocolClientFactory {
  @override
  String get scheme => "http";

  /// The [HttpConfig] used to configure new clients.
  final HttpConfig? httpConfig;

  /// Creates a new [HttpClientFactory] based on an optional [HttpConfig].
  HttpClientFactory([this.httpConfig]);

  @override
  bool destroy() {
    // TODO(JKRhb): Check if there is anything to destroy.
    return true;
  }

  @override
  ProtocolClient createClient() => HttpClient(httpConfig);

  @override
  bool init() {
    // TODO(JKRhb): Check if there is anything to init.
    return true;
  }
}
