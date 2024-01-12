// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:async";

import "package:coap/coap.dart";
import "package:collection/collection.dart";
import "package:multicast_dns/multicast_dns.dart";

import "../definitions.dart";
import "../scripting_api.dart" as scripting_api;
import "content.dart";
import "discovery_exception.dart";
import "protocol_interfaces/protocol_client.dart";
import "servient.dart";

/// Implemention of the [scripting_api.ThingDiscovery] interface.
class ThingDiscovery extends Stream<ThingDescription>
    implements scripting_api.ThingDiscovery {
  /// Creates a new [ThingDiscovery] object with a given [thingFilter].
  ThingDiscovery(
    this._url,
    this.thingFilter,
    this._servient, {
    required scripting_api.DiscoveryMethod method,
  }) : _method = method {
    _stream = _start();
  }

  /// Represents the discovery type that should be used in the discovery process
  final scripting_api.DiscoveryMethod _method;

  /// Represents the URL of the target entity serving the discovery request.
  ///
  /// This is, for instance the URL of a Thing Directory (if [_method] is
  /// [scripting_api.DiscoveryMethod.directory]), or the URL of a directly
  /// targeted Thing (if [_method] is [scripting_api.DiscoveryMethod.direct]).
  final Uri _url;

  final Servient _servient;

  final Map<String, ProtocolClient> _clients = {};

  bool _active = true;

  @override
  bool get active => _active;

  @override
  final scripting_api.ThingFilter? thingFilter;

  late final Stream<ThingDescription> _stream;

  Stream<ThingDescription> _start() async* {
    switch (_method) {
      case scripting_api.DiscoveryMethod.direct:
        yield* _discoverDirectly(_url);
      case scripting_api.DiscoveryMethod.coreLinkFormat:
        yield* _discoverWithCoreLinkFormat(_url);
      case scripting_api.DiscoveryMethod.coreResourceDirectory:
        yield* _discoverfromCoreResourceDirectory(_url);
      case scripting_api.DiscoveryMethod.dnsServiceDiscovery:
        yield* _discoverUsingDnsServiceDiscovery(_url);
      default:
        throw UnimplementedError();
    }
  }

  ProtocolClient _clientForUriScheme(Uri uri) {
    final uriScheme = uri.scheme;
    final existingClient = _clients[uriScheme];

    if (existingClient != null) {
      return existingClient;
    }

    final newClient = _servient.clientFor(uriScheme);
    _clients[uriScheme] = newClient;
    return newClient;
  }

  @override
  Future<void> stop() async {
    final stopFutures = _clients.values.map((client) => client.stop());
    await Future.wait(stopFutures);
    _clients.clear();
    _active = false;
  }

  Future<ThingDescription> _decodeThingDescription(
    DiscoveryContent content,
  ) async {
    final dataSchemaValue =
        await _servient.contentSerdes.contentToValue(content, null);
    if (dataSchemaValue
        is! scripting_api.DataSchemaValue<Map<String, Object?>>) {
      throw DiscoveryException(
        "Could not parse Thing Description obtained from ${content.sourceUri}",
      );
    }

    return ThingDescription.fromJson(dataSchemaValue.value);
  }

  Stream<ThingDescription> _discoverDirectly(Uri uri) async* {
    final client = _clientForUriScheme(uri);

    yield* client
        .discoverDirectly(uri, disableMulticast: true)
        .asyncMap(_decodeThingDescription);
  }

  Future<List<CoapWebLink>> _getCoreWebLinks(
    Content content,
    Uri sourceUri,
  ) async {
    final dataSchemaValue =
        await _servient.contentSerdes.contentToValue(content, null);

    if (dataSchemaValue is! scripting_api.DataSchemaValue<String>) {
      throw DiscoveryException(
        "Could not parse Thing Description obtained from $sourceUri",
      );
    }

    return CoapLinkFormat.parse(dataSchemaValue.value).toList();
  }

  Future<Iterable<Uri>> _filterCoreWebLinks(
    String resourceType,
    DiscoveryContent coreWebLink,
  ) async {
    final sourceUri = coreWebLink.sourceUri;
    final webLinks = await _getCoreWebLinks(coreWebLink, sourceUri);

    return webLinks
        .where(
          (element) =>
              element.attributes.getResourceTypes()?.contains(resourceType) ??
              false,
        )
        .map((weblink) => Uri.tryParse(weblink.uri))
        .whereType<Uri>()
        .map((uri) => uri.toAbsoluteUri(sourceUri));
  }

  Stream<ThingDescription> _discoverWithCoreLinkFormat(Uri uri) async* {
    // TODO: Remove additional quotes once fixed in CoAP library
    yield* _performCoreLinkFormatDiscovery('"wot.thing"', uri)
        .map(_discoverDirectly)
        .flatten();
  }

  Stream<ThingDescription> _discoverfromCoreResourceDirectory(Uri uri) async* {
    // TODO: Remove additional quotes once fixed in CoAP library
    yield* _performCoreLinkFormatDiscovery('"core.rd-lookup-res"', uri)
        .map(_discoverWithCoreLinkFormat)
        .flatten();
  }

  Stream<Uri> _performCoreLinkFormatDiscovery(
    String resourceType,
    Uri uri,
  ) async* {
    final Set<Uri> discoveredUris = {};
    final discoveryUri = uri.toLinkFormatDiscoveryUri(resourceType);
    final client = _clientForUriScheme(uri);

    await for (final coreWebLink
        in client.discoverWithCoreLinkFormat(discoveryUri)) {
      final Iterable<Uri> parsedUris;

      try {
        parsedUris = await _filterCoreWebLinks(resourceType, coreWebLink);
      } on Exception catch (exception) {
        yield* Stream.error(exception);
        continue;
      }

      for (final parsedUri in parsedUris) {
        final uriAdded = discoveredUris.add(parsedUri);

        if (!uriAdded) {
          continue;
        }

        yield parsedUri;
      }
    }
  }

  @override
  StreamSubscription<ThingDescription> listen(
    void Function(ThingDescription event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    Future<void> cleanUpAndDone() async {
      await stop();
      if (onDone != null) {
        onDone();
      }
    }

    return _stream.listen(
      onData,
      onError: onError,
      onDone: cleanUpAndDone,
      cancelOnError: cancelOnError,
    );
  }

  Stream<ThingDescription> _discoverUsingDnsServiceDiscovery(Uri url) async* {
    final dnsName = url.toString();

    if (dnsName.endsWith("local")) {
      yield* _discoverUsingMdnssd(dnsName);
    } else {
      throw UnimplementedError("Only mDNS-SD is currently supported!");
    }
  }

  // TODO(JKRhb): Should be handled in a more robust way
  bool _isUdpDiscovery(String name) {
    if (name.contains("_udp")) {
      return true;
    }

    if (name.contains("_tcp")) {
      return false;
    }

    // TODO(JKRhb): Check if this error message is correct.
    throw DiscoveryException(
      "Service name $name neither includes _udp nor _tcp",
    );
  }

  Future<Map<String, String>?> _lookupTxtRecords(
    MDnsClient client,
    String domainName,
  ) async {
    final txtRecords = await client
        .lookup<TxtResourceRecord>(ResourceRecordQuery.text(domainName))
        .toList();
    final recordsList = txtRecords.firstOrNull?.text
        .split("\n")
        .map((property) => property.split("="))
        .where((list) => list.length > 1)
        .map((list) => MapEntry(list[0], list[1]));

    if (recordsList == null) {
      return null;
    }

    return Map.fromEntries(recordsList);
  }

  Stream<ThingDescription> _discoverUsingMdnssd(String name) async* {
    final MDnsClient client = MDnsClient();
    await client.start();

    final discoveredUris = <Uri>{};
    final defaultScheme = _isUdpDiscovery(name) ? "coap" : "http";
    const defaultType = "Thing";

    await for (final PtrResourceRecord ptr in client
        .lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(name))) {
      final query = ResourceRecordQuery.service(ptr.domainName);

      await for (final SrvResourceRecord srv
          in client.lookup<SrvResourceRecord>(query)) {
        final txtRecords = await _lookupTxtRecords(client, ptr.domainName);

        if (txtRecords == null) {
          continue;
        }

        final uri = Uri(
          host: srv.target,
          port: srv.port,
          path: txtRecords["td"],
          scheme: txtRecords["scheme"] ?? defaultScheme,
        );

        final duplicate = !discoveredUris.add(uri);

        if (duplicate) {
          continue;
        }

        final type = txtRecords["type"] ?? defaultType;

        switch (type) {
          case "Thing":
            yield* _discoverDirectly(uri);
          case "Directory":
            // TODO(JKRhb): Implement directory discovery.
            break;
        }
      }
    }

    client.stop();
  }
}

extension _UriExtension on Uri {
  /// Returns the [path] if it is not empty, otherwise `null`.
  String? get _pathOrNull {
    if (path.isNotEmpty) {
      return path;
    }

    return null;
  }

  /// Converts this [Uri] to one usable for CoRE Resource Discovery.
  ///
  /// If no path should be given (i.e., it is empty) `/.well-known/core` will be
  /// used as a default.
  ///
  /// The specified [resourceType] will be added to the [queryParameters] using
  /// the parameter name `rt`. If this name should already be in use, it will
  /// not be overridden.
  Uri toLinkFormatDiscoveryUri(String resourceType) {
    final Map<String, dynamic> newQueryParameters = {"rt": resourceType};
    if (queryParameters.isNotEmpty) {
      newQueryParameters.addAll(queryParameters);
    }

    return replace(
      path: _pathOrNull ?? "/.well-known/core",
      queryParameters: newQueryParameters,
    );
  }

  /// Converts this [Uri] into an absolute one using a [baseUri].
  ///
  /// If this [Uri] should already be an absolute one, it is returned directly.
  Uri toAbsoluteUri(Uri baseUri) {
    if (isAbsolute) {
      return this;
    }

    return replace(
      scheme: baseUri.scheme,
      host: baseUri.host,
      port: baseUri.port,
    );
  }
}

/// Extension to simplify the handling of nested [Stream]s.
extension _FlatStreamExtension<T> on Stream<Stream<T>> {
  /// Flattens a nested [Stream] of [Stream]s into a single [Stream].
  Stream<T> flatten() async* {
    await for (final stream in this) {
      yield* stream;
    }
  }
}

/// Implemention of the [scripting_api.ThingDiscoveryProcess] interface.
class ThingDiscoveryProcess extends Stream<ThingDescription>
    implements scripting_api.ThingDiscoveryProcess {
  /// Constructs a new [ThingDiscoveryProcess].
  ///
  /// Accepts a [_thingDescriptionStream], which is filtered by an optional
  /// [thingFilter].
  ThingDiscoveryProcess(
    this._thingDescriptionStream,
    this.thingFilter,
  );

  StreamSubscription<ThingDescription>? _streamSubscription;

  final Stream<ThingDescription> _thingDescriptionStream;

  var _done = false;

  @override
  bool get done => _done;

  Exception? _error;

  @override
  Exception? get error => _error;

  @override
  final scripting_api.ThingFilter? thingFilter;

  @override
  StreamSubscription<ThingDescription> listen(
    void Function(ThingDescription event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final streamSubscription = _thingDescriptionStream.listen(
      onData,
      onError: (error, stackTrace) {
        if (error is Exception) {
          _error = error;
          // ignore: avoid_dynamic_calls
          onError?.call(error, stackTrace);
        }
      },
      onDone: () {
        _done = true;
        onDone?.call();
      },
      cancelOnError: cancelOnError,
    );

    _streamSubscription = streamSubscription;

    return streamSubscription;
  }

  @override
  Future<void> stop() async {
    if (done) {
      return;
    }

    await _streamSubscription?.cancel();

    _done = true;
  }
}
