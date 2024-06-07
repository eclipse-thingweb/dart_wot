// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:io" as io;

import "../../core.dart";

import "http_config.dart";

const _thingsPath = "/things";

/// A [ProtocolServer] for the Hypertext Transfer Protocol (HTTP).
final class HttpServer implements ProtocolServer {
  /// Create a new [HttpServer] from an optional [HttpConfig].
  HttpServer(HttpConfig? httpConfig)
      // TODO(JKRhb): Check if the scheme should be determined differently.
      : scheme = httpConfig?.secure ?? false ? "https" : "http",
        port = _portFromConfig(httpConfig);

  @override
  final String scheme;

  @override
  final int port;

  // FIXME
  final Object _bindAddress = io.InternetAddress.loopbackIPv4;

  io.HttpServer? _server;

  final _things = <String, ExposedThing>{};

  late final Servient _servient;

  static int _portFromConfig(HttpConfig? httpConfig) {
    final secure = httpConfig?.secure ?? false;

    return httpConfig?.port ?? (secure ? 443 : 80);
  }

  @override
  Future<void> expose(ExposedThing thing) async {
    final key = thing.thingDescription.identifier;
    _things[key] = thing;
  }

  @override
  Future<void> start(Servient servient) async {
    if (_server != null) {
      throw StateError("Server already started");
    }

    _server = await io.HttpServer.bind(_bindAddress, port);

    _server?.listen(_handleRequest);

    // final handler = const shelf.Pipeline()
    //     .addMiddleware(shelf.logRequests())
    //     .addHandler(_handleRequest);

    // final server = await shelf_io.serve(handler, _bindAddress, port);

    // Enable content compression
    // server.autoCompress = true;

    // _server = server;
    _servient = servient;
  }

  @override
  Future<void> stop() async {
    // await _server?.close();
    _server = null;
  }

  Future<void> _handleRequest(io.HttpRequest request) async {
    final path = request.uri.path;

    if (path.startsWith(_thingsPath)) {
      await _handleThingRequest(request);
    }
  }

  Future<void> _handleThingRequest(io.HttpRequest request) async {
    final response = request.response;
    if (request.method != "GET") {
      response
        ..statusCode = 405
        ..write("Method not allowed");
      await response.close();
      return;
    }

    final path = request.uri.pathSegments.sublist(1).join("/");

    final exposedThing = _things[path];

    if (exposedThing == null) {
      response
        ..statusCode = 404
        ..write("Not found");
      await response.close();
      return;
    }

    // TODO: Fix content negotiation
    final acceptHeader = request.headers["Accept"]?[0];
    final contentType = ["*/*", null].contains(acceptHeader)
        ? "application/td+json"
        : acceptHeader;

    print(exposedThing.thingDescription.forms);

    final rawThingDescription = exposedThing.thingDescription.toJson();

    final dataSchemaValue = DataSchemaValue.tryParse(rawThingDescription);

    // FIXME: Thing Description is not generated correctly
    final content = _servient.contentSerdes.valueToContent(
      dataSchemaValue,
      null,
      contentType ?? "application/td+json",
    );

    response.statusCode = 404;
    await response.addStream(content.body);
    await response.close();
  }

  // Response _handleRequest(shelf.Request request) {
  //   final path = request.url.path;

  //   if (path.startsWith(_thingsPath)) {
  //     return _handleThingRequest(request);
  //   }

  //   return shelf.Response.notFound('Not found.');
  // }
}
