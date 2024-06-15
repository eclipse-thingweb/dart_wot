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

  final _things = <String, ExposableThing>{};

  late final Servient _servient;

  final Map<String, Router> _routes = {};

  static int _portFromConfig(HttpConfig? httpConfig) {
    final secure = httpConfig?.secure ?? false;

    return httpConfig?.port ?? (secure ? 443 : 80);
  }

  @override
  Future<void> expose(ExposableThing thing) async {
    final thingDescription = thing.thingDescription;
    final thingId = thingDescription.id;

    if (thingId == null) {
      throw ArgumentError("Missing id field in thingDescription.");
    }

    _things[thingId] = thing;

    final router = Router();

    final affordances = [
      ...thingDescription.actions?.entries ?? [],
      ...thingDescription.properties?.entries ?? [],
      ...thingDescription.events?.entries ?? [],
    ];

    for (final affordance in affordances) {
      final affordanceKey = affordance.key;
      final affordanceValue = affordance.value;

      switch (affordanceValue) {
        // TODO: Refactor
        // TODO: Handle values from protocol bindings
        case Property(:final readOnly, :final writeOnly):
          final path = "/$thingId/$affordanceKey";
          if (!writeOnly) {
            router.get(path, (request) async {
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

          if (!readOnly) {
            router.post(path, (request) async {
              if (request is! Request) {
                throw Exception();
              }

              final content = Content(
                request.mimeType ?? "application/json",
                request.read(),
              );
              await thing.handleWriteProperty(affordance.key, content);

              return Response(
                204,
              );
            });

            // TODO: Handle observe
          }
        default:
          continue;
      }
    }

    _routes[thingId] = router;
  }

  @override
  Future<void> start(Servient servient) async {
    if (_server != null) {
      throw StateError("Server already started");
    }

    _server = await shelf_io.serve(_handleRequest, _bindAddress, port);

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

    final router = _routes[firstSegment];

    if (router != null) {
      return router.call(request);
    }

    if (firstSegment == _thingsPath) {
      return _handleThingRequest(request);
    }

    return Response.notFound("Not found.");
  }

  Future<Response> _handleThingRequest(Request request) async {
    if (request.method != "GET") {
      return Response(405, body: "Method not allowed");
    }

    final path = request.requestedUri.pathSegments.sublist(1).join("/");

    final exposedThing = _things[path];

    if (exposedThing == null) {
      return Response.notFound("Not found.");
    }

    // TODO: Fix content negotiation
    final acceptHeader = request.headers["Accept"]?[0];
    final contentType = ["*/*", null].contains(acceptHeader)
        ? "application/td+json"
        : acceptHeader;

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
