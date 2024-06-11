// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

// import "dart:io" as io;

import "dart:io" as io;

import "package:shelf/shelf.dart";
import "package:shelf/shelf_io.dart" as shelf_io;
import "package:shelf_router/shelf_router.dart";

import "../../core.dart" hide ExposedThing;

import "../core/implementation/exposed_thing.dart";
import "http_config.dart";

const _thingsPath = "things";

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

  final Map<String, Router> _routes = {};

  static int _portFromConfig(HttpConfig? httpConfig) {
    final secure = httpConfig?.secure ?? false;

    return httpConfig?.port ?? (secure ? 443 : 80);
  }

  @override
  Future<void> expose(ExposedThing thing) async {
    final thingDescription = thing.thingDescription;
    final key = thingDescription.id;

    print(key);

    if (key == null) {
      throw ArgumentError("Missing id field in thingDescription.");
    }

    _things[key] = thing;

    final router = Router();

    // final affordances = [
    //   ...thingDescription.actions?.entries ?? [],
    //   ...thingDescription.properties?.entries ?? [],
    //   ...thingDescription.events?.entries ?? [],
    // ];

    for (final affordance in thingDescription.properties?.entries ??
        <MapEntry<String, Property>>[]) {
      print("/$key/${affordance.key}");
      router.get("/$key/${affordance.key}", (request, name) async {
        final content = await thing.handleReadProperty(affordance.key);

        return Response(
          200,
          body: content.body,
          headers: {
            "Content-Type": content.type,
          },
        );
      });
    }

    _routes[key] = router;
  }

  @override
  Future<void> start(Servient servient) async {
    if (_server != null) {
      throw StateError("Server already started");
    }

    // _server = await io.HttpServer.bind(_bindAddress, port);
    _server = await shelf_io.serve(_handleRequest, _bindAddress, port);

    // _server?.listen(_handleRequest);

    print("Started!");

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
    await _server?.close();
    _server = null;
  }

  Future<Response> _handleRequest(Request request) async {
    final requestedUri = request.requestedUri;

    final firstSegment = requestedUri.pathSegments.firstOrNull;

    print(_routes);
    print(firstSegment);

    final router = _routes[firstSegment];

    if (router != null) {
      print("yeah");
      print(request.handlerPath);
      return router.call(request);
    }

    print(firstSegment);

    if (firstSegment == _thingsPath) {
      print("yo");
      return _handleThingRequest(request);
    }

    return Response.notFound("Not found.");
  }

  Future<Response> _handleThingRequest(Request request) async {
    if (request.method != "GET") {
      return Response(405, body: "Method not allowed");
    }

    final path = request.requestedUri.pathSegments.sublist(1).join("/");

    print(_things);

    final exposedThing = _things[path];

    if (exposedThing == null) {
      return Response.notFound("Not found.");
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

    return Response(200, body: content.body);
  }

  // Response _handleRequest(shelf.Request request) {
  //   final path = request.url.path;

  //   if (path.startsWith(_thingsPath)) {
  //     return _handleThingRequest(request);
  //   }

  //   return shelf.Response.notFound('Not found.');
  // }
}
