// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/src/binding_http/http_config.dart';

import '../core/protocol_interfaces/protocol_server.dart';
import '../definitions/credentials/credentials.dart';
import '../scripting_api/exposed_thing.dart';

/// A [ProtocolServer] for the Hypertext Transfer Protocol (HTTP).
class HttpServer extends ProtocolServer {
  final String _scheme;

  final int _port;

  final HttpConfig? _httpConfig;

  Map<String, Map<String, Credentials>> _credentials = {};

  /// Create a new [HttpServer] from an optional [HttpConfig].
  HttpServer(this._httpConfig)
      // TODO(JKRhb): Check if the scheme should be determined differently.
      : _scheme = _httpConfig?.secure ?? false ? "https" : "http",
        _port = _portFromConfig(_httpConfig);

  static int _portFromConfig(HttpConfig? httpConfig) {
    final secure = httpConfig?.secure ?? false;

    return httpConfig?.port ?? (secure ? 443 : 80);
  }

  @override
  Future<void> expose(ExposedThing thing) {
    // TODO: implement expose
    throw UnimplementedError();
  }

  @override
  int get port => _port;

  @override
  String get scheme => _scheme;

  @override
  Future<void> start(Map<String, Map<String, Credentials>> credentials) async {
    _credentials = credentials;
  }

  @override
  Future<void> stop() async {
    // TODO(JKRhb): implement stop
  }
}
