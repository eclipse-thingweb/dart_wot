// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../core/protocol_interfaces/protocol_client.dart';
import '../core/protocol_interfaces/protocol_client_factory.dart';
import '../core/security_provider.dart';
import 'http_client.dart';
import 'http_config.dart';

/// A [ProtocolClientFactory] that produces HTTP and HTTPS clients.
final class HttpClientFactory implements ProtocolClientFactory {
  /// Creates a new [HttpClientFactory] based on an optional [HttpConfig].
  HttpClientFactory([this.httpConfig]);

  @override
  Set<String> get schemes => {'http', 'https'};

  /// The [HttpConfig] used to configure new clients.
  final HttpConfig? httpConfig;

  @override
  bool destroy() {
    return true;
  }

  @override
  ProtocolClient createClient([
    ClientSecurityProvider? clientSecurityProvider,
  ]) =>
      HttpClient(clientSecurityProvider);

  @override
  bool init() {
    return true;
  }
}
