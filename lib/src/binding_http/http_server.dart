// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/src/binding_http/http_config.dart';

import '../core/protocol_interfaces/protocol_server.dart';
import '../core/security_provider.dart';
import '../scripting_api/exposed_thing.dart';

/// A [ProtocolServer] for the Hypertext Transfer Protocol (HTTP).
class HttpServer extends ProtocolServer {
  @override
  final String scheme;

  @override
  final int port;

  /// Create a new [HttpServer] from an optional [HttpConfig].
  HttpServer(HttpConfig? _httpConfig)
      // TODO(JKRhb): Check if the scheme should be determined differently.
      : scheme = _httpConfig?.secure ?? false ? "https" : "http",
        port = _portFromConfig(_httpConfig);

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
