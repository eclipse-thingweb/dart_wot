// Copyright 2022 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import '../core/protocol_interfaces/protocol_client_factory.dart';
import 'http_client_factory.dart';
import 'http_config.dart';

/// A [ProtocolClientFactory] that produces HTTPS clients.
// TODO(JKRhb): Not sure if two Factory classes make that much sense. Maybe it
//              would be better to have one Factory that has a List of supported
//              schemes (i. e. both http and https in this case).
//              At the moment, this is the approach taken from node-wot, though.
class HttpsClientFactory extends HttpClientFactory {
  @override
  String get scheme => "https";

  /// Creates a new [HttpClientFactory] based on an optional [HttpConfig].
  HttpsClientFactory([HttpConfig? _httpConfig]) : super(_httpConfig);
}
