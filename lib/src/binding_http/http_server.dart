// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../core/protocol_interfaces/protocol_server.dart';
import '../core/security_provider.dart';
import '../scripting_api/exposed_thing.dart';
import 'http_config.dart';

/// A [ProtocolServer] for the Hypertext Transfer Protocol (HTTP).
final class HttpServer implements ProtocolServer {
  /// Create a new [HttpServer] from an optional [HttpConfig].
  HttpServer(HttpConfig? httpConfig)
      // TODO(JKRhb): Check if the scheme should be determined differently.
      : scheme = httpConfig?.secure ?? false ? 'https' : 'http',
        port = _portFromConfig(httpConfig);

  @override
  final String scheme;

  @override
  final int port;

  static int _portFromConfig(HttpConfig? httpConfig) {
    final secure = httpConfig?.secure ?? false;

    return httpConfig?.port ?? (secure ? 443 : 80);
  }

  @override
  Future<void> expose(ExposedThing thing) {
    // TODO(JKRhb): implement expose
    throw UnimplementedError();
  }

  @override
  Future<void> start([ServerSecurityCallback? serverSecurityCallback]) async {
    // TODO(JKRhb): implement start
    throw UnimplementedError();
  }

  @override
  Future<void> stop() async {
    // TODO(JKRhb): implement stop
    throw UnimplementedError();
  }
}
