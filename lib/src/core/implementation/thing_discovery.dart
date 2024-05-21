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
import "../exceptions.dart";
import "../scripting_api.dart" as scripting_api;
import "content.dart";
import "discovery/discovery_configuration.dart";
import "protocol_interfaces/protocol_client.dart";
import "servient.dart";

/// Implementation of the [scripting_api.ThingDiscovery] interface.
class ThingDiscovery extends Stream<ThingDescription>
    implements scripting_api.ThingDiscovery {
  /// Creates a new [ThingDiscovery] object with a given [thingFilter].
  ThingDiscovery(this.thingFilter, this._servient) {
    _stream = _start();
  }

  final InternalServient _servient;

  final Map<String, ProtocolClient> _clients = {};

  final Set<Uri> _discoveredUris = {};

  bool _active = true;

  @override
  bool get active => _active;

  @override
  final scripting_api.ThingFilter? thingFilter;

  late final Stream<ThingDescription> _stream;

  Stream<ThingDescription> _start() async* {
    for (final discoveryParameter in _servient.discoveryConfigurations) {
      switch (discoveryParameter) {
        case DnsSdDConfiguration(
            :final discoveryType,
            domainName: final domain,
            :final protocolType,
          ):
          yield* _discoverUsingDnsSd(discoveryType, domain, protocolType);
        case CoreLinkFormatConfiguration(
            :final uri,
            :final discoveryType,
          ):
          yield* _discoverWithCoreLinkFormat(uri, discoveryType);
        case CoreResourceDirectoryConfiguration(
            :final uri,
            :final discoveryType,
          ):
          yield* _discoverfromCoreResourceDirectory(uri, discoveryType);
        case DirectConfiguration(:final uri):
          yield* Stream.fromFuture(_servient.requestThingDescription(uri));
      }
    }
  }

  ProtocolClient _clientForUriScheme(String scheme) {
    final existingClient = _clients[scheme];
    if (existingClient != null) {
      return existingClient;
    }
    final newClient = _servient.clientFor(scheme);
    _clients[scheme] = newClient;
    return newClient;
  }

  /// Removes the leading and trailing `.` from a [domainName], if present.
  String _processDomainName(String domainName) {
    final int startIndex;
    final int endIndex;

    if (domainName.startsWith(".")) {
      startIndex = 1;
    } else {
      startIndex = 0;
    }

    if (domainName.endsWith(".")) {
      endIndex = domainName.length - 1;
    } else {
      endIndex = domainName.length;
    }

    return domainName.substring(startIndex, endIndex);
  }

  Stream<ThingDescription> _discoverUsingDnsSd(
    DiscoveryType discoveryType,
    String domainName,
    ProtocolType protocolType,
  ) async* {
    if (domainName != ".local") {
      throw UnimplementedError(
        "Only multicast DNS is supported at the moment.",
      );
    }

    final serviceNameSegments = <String>[];

    if (discoveryType == DiscoveryType.directory) {
      serviceNameSegments.addAll(const ["_directory", "_sub"]);
    }

    serviceNameSegments
      ..add("_wot")
      ..add(protocolType.dnsSdProtocolLabel)
      ..add(_processDomainName(domainName));

    final fullDomainName = serviceNameSegments.join(".");

    yield* _performMdnsDiscovery(
      fullDomainName,
      protocolType.defaultDnsSdUriScheme,
      discoveryType,
    );
  }

  Stream<ThingDescription> _performMdnsDiscovery(
    String domainName,
    String defaultUriScheme,
    DiscoveryType expectedType,
  ) async* {
    final MDnsClient client = MDnsClient();
    await client.start();

    const defaultType = "Thing";

    await for (final PtrResourceRecord ptr in client.lookup<PtrResourceRecord>(
      ResourceRecordQuery.serverPointer(domainName),
    )) {
      final query = ResourceRecordQuery.service(ptr.domainName);

      await for (final SrvResourceRecord srv
          in client.lookup<SrvResourceRecord>(query)) {
        final txtRecords = await _lookupTxtRecords(client, ptr.domainName);

        if (txtRecords == null) {
          continue;
        }

        final discoveredType = txtRecords["type"] ?? defaultType;

        if (discoveredType != expectedType.dnsDsType) {
          continue;
        }

        final uri = Uri(
          host: srv.target,
          port: srv.port,
          path: txtRecords["td"],
          scheme: txtRecords["scheme"] ?? defaultUriScheme,
        );

        final duplicate = !_discoveredUris.add(uri);

        if (duplicate) {
          continue;
        }

        final thingDescription = await _servient.requestThingDescription(uri);

        yield thingDescription;
      }
    }

    client.stop();
  }

  Stream<Iterable<Uri>> _performCoreLinkFormatDiscovery(
    Uri uri,
    String resourceType,
  ) async* {
    final client = _clientForUriScheme(uri.scheme);

    await for (final coreWebLink in client.discoverWithCoreLinkFormat(uri)) {
      try {
        final parsedUris = await _filterCoreWebLinks(resourceType, coreWebLink);
        yield parsedUris.where(_discoveredUris.add);
      } on Exception catch (exception) {
        yield* Stream.error(exception);
        continue;
      }
    }
  }

  Stream<ThingDescription> _discoverWithCoreLinkFormat(
    Uri uri,
    DiscoveryType discoveryType,
  ) async* {
    await for (final coreWebLinks in _performCoreLinkFormatDiscovery(
      uri,
      discoveryType.coreLinkFormatResourceType,
    )) {
      final futures = coreWebLinks.map(_servient.requestThingDescription);
      yield* Stream.fromFutures(futures);
    }
  }

  Stream<ThingDescription> _discoverfromCoreResourceDirectory(
    Uri uri,
    DiscoveryType discoveryType,
  ) async* {
    yield* _performCoreLinkFormatDiscovery(
      uri,
      "core.rd-lookup-res",
    ).transform(
      StreamTransformer.fromBind((stream) async* {
        await for (final uris in stream) {
          for (final uri in uris) {
            yield* _discoverWithCoreLinkFormat(uri, discoveryType);
          }
        }
      }),
    );
  }

  @override
  Future<void> stop() async {
    final stopFutures = _clients.values.map((client) => client.stop());
    await Future.wait(stopFutures);
    _clients.clear();
    _active = false;
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
              element.attributes
                  .getResourceTypes()
                  ?.contains(resourceType.asCoreLinkFormatAttributeValue()) ??
              false,
        )
        .map((webLink) => Uri.tryParse(webLink.uri))
        .whereType<Uri>()
        .map((uri) => uri.toAbsoluteUri(sourceUri));
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
}

extension _CoreLinkFormatExtension on String {
  /// Formats this string as an attribute value for the CoRE Link-Format.
  // TODO: Remove additional quotes once fixed in CoAP library
  String asCoreLinkFormatAttributeValue() => '"$this"';
}

extension _UriExtension on Uri {
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

/// Implementation of the [scripting_api.ThingDiscoveryProcess] interface.
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
