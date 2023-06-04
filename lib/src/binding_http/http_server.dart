// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:io" as io;

import "package:shelf/shelf.dart";
import "package:shelf/shelf_io.dart" as shelf_io;
import "package:shelf_router/shelf_router.dart";

import "../../core.dart" hide ExposedThing;

import "http_config.dart";
import "http_extensions.dart";

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

    final router = Router()
      ..get("/$thingId", (request) {
        const defaultContentType = "application/td+json";
        return Response(
          200,
          body: _servient.contentSerdes
              .valueToContent(
                DataSchemaValue.tryParse(
                  thingDescription.toJson(),
                ),
                null,
                defaultContentType,
              )
              .body,
          headers: {
            "Content-Type": defaultContentType,
          },
        );
      });

    final affordances = <MapEntry<String, InteractionAffordance>>[];

    for (final affordanceMap in [
      thingDescription.actions,
      thingDescription.properties,
      thingDescription.events,
    ]) {
      affordanceMap?.entries.forEach(affordances.add);
    }

    for (final affordance in affordances) {
      final affordanceKey = affordance.key;
      final affordanceValue = affordance.value;

      // TODO: Integrate URI variables here
      final path = "/$thingId/$affordanceKey";
      final affordanceUri = Uri(
        scheme: "http",
        host: _server!.address.address,
        port: _server!.port,
        path: path,
      );

      switch (affordanceValue) {
        // TODO: Refactor
        // TODO: Handle values from protocol bindings
        case Property(:final readOnly, :final writeOnly, :final observable):
          if (!writeOnly) {
            const operationType = OperationType.readproperty;
            final methodName = operationType.defaultHttpMethod;
            router.add(methodName, path, (request) async {
              final content = await thing.handleReadProperty(affordance.key);

              return Response(
                200,
                body: content.body,
                headers: {
                  "Content-Type": content.type,
                },
              );
            });

            affordanceValue.forms.add(
              Form(
                affordanceUri,
                op: const [
                  operationType,
                ],
              ),
            );
          }

          if (!readOnly) {
            const operationType = OperationType.writeproperty;
            final methodName = operationType.defaultHttpMethod;
            router.add(methodName, path, (request) async {
              if (request is! Request) {
                throw Exception();
              }

              final content = Content(
                request.mimeType ?? "application/json",
                request.read(),
              );
              try {
                await thing.handleWriteProperty(affordance.key, content);
              } on FormatException {
                return Response.badRequest();
              }

              return Response(
                204,
              );
            });

            affordanceValue.forms.add(
              Form(
                affordanceUri,
                op: const [
                  operationType,
                ],
              ),
            );
          }

          if (observable) {
            const _ = [
              OperationType.observeproperty,
              OperationType.unobserveproperty,
            ];

            // TODO: Implement some kind of event mechanism (e.g., longpolling)
          }
        case Action():
          const operationType = OperationType.invokeaction;
          final methodName = operationType.defaultHttpMethod;
          router.add(methodName, path, (request) async {
            if (request is! Request) {
              throw Exception();
            }

            final content = Content(
              request.mimeType ?? "application/json",
              request.read(),
            );
            final actionOutput =
                await thing.handleInvokeAction(affordance.key, content);

            return Response(
              body: actionOutput?.body,
              204,
            );
          });

          affordanceValue.forms.add(
            Form(
              affordanceUri,
              op: const [
                operationType,
              ],
            ),
          );

        case Event():
          const _ = [
            OperationType.subscribeevent,
            OperationType.unsubscribeevent,
          ];

        // TODO: Implement some kind of event mechanism (e.g., longpolling)
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

    return Response.notFound("Not found.");
  }

  @override
  Future<void> destroyThing(ExposableThing thing) async {
    final id = thing.thingDescription.id;

    _things.remove(id);
    _routes.remove(id);
  }
}
