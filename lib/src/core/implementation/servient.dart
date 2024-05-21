// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:meta/meta.dart";
import "package:uuid/uuid.dart";

import "../definitions.dart";
import "../definitions/context.dart";
import "../exceptions.dart";
import "../scripting_api.dart" as scripting_api;
import "consumed_thing.dart";
import "content_serdes.dart";
import "discovery/discovery_configuration.dart";
import "exposed_thing.dart";
import "protocol_interfaces/protocol_client.dart";
import "protocol_interfaces/protocol_client_factory.dart";
import "protocol_interfaces/protocol_server.dart";
import "thing_discovery.dart";
import "wot.dart";

/// A software stack that implements the WoT building blocks.
///
/// A [Servient] can host and expose Things and/or host Consumers that consume
/// Things. Servients can support multiple Protocol Bindings to enable
/// interaction with different IoT platforms.
abstract class Servient {
  /// Creates a new [Servient].
  ///
  /// The [Servient] can be pre-configured with [List]s of
  /// [clientFactories] and [discoveryConfigurations].
  /// However, it is also possible to dynamically [addClientFactory]s and
  /// [removeClientFactory]s at runtime.
  ///
  /// If you want to support a custom media type not already included in the
  /// [ContentSerdes] class, a custom [contentSerdes] object can be passed as an
  /// argument.
  factory Servient.create({
    List<ProtocolClientFactory>? clientFactories,
    ServerSecurityCallback? serverSecurityCallback,
    ContentSerdes? contentSerdes,
    List<DiscoveryConfiguration>? discoveryConfigurations,
  }) {
    return InternalServient(
      clientFactories: clientFactories,
      serverSecurityCallback: serverSecurityCallback,
      contentSerdes: contentSerdes,
      discoveryConfigurations: discoveryConfigurations,
    );
  }

  /// [List] of [DiscoveryConfiguration]s that are used when calling the
  /// [scripting_api.WoT.discover] method.
  List<DiscoveryConfiguration> get discoveryConfigurations;

  set discoveryConfigurations(
    List<DiscoveryConfiguration> discoveryConfigurations,
  );

  /// Starts this [Servient] and returns a [WoT] runtime object.
  ///
  /// The [scripting_api.WoT] runtime can be used for consuming, producing, and
  /// discovering Things.
  Future<scripting_api.WoT> start();

  /// Adds a new [clientFactory] to this [Servient].
  void addClientFactory(ProtocolClientFactory clientFactory);

  /// Removes a [ProtocolClientFactory] matching the given [scheme] from this
  /// [Servient], if present.
  ///
  /// If a [ProtocolClientFactory] was removed, the method returns it, otherwise
  /// the return value is `null`.
  ProtocolClientFactory? removeClientFactory(String scheme);

  /// Closes this [Servient] and cleans up all resources.
  Future<void> shutdown();
}

/// Provides the internal implementation details of the [Servient] class.
class InternalServient implements Servient {
  /// Creates a new [InternalServient].
  InternalServient({
    List<ProtocolClientFactory>? clientFactories,
    ServerSecurityCallback? serverSecurityCallback,
    ContentSerdes? contentSerdes,
    List<DiscoveryConfiguration>? discoveryConfigurations,
  })  : contentSerdes = contentSerdes ?? ContentSerdes(),
        discoveryConfigurations = discoveryConfigurations ?? [],
        _serverSecurityCallback = serverSecurityCallback {
    for (final clientFactory in clientFactories ?? <ProtocolClientFactory>[]) {
      addClientFactory(clientFactory);
    }
  }

  final List<ProtocolServer> _servers = [];
  final Map<String, ProtocolClientFactory> _clientFactories = {};
  final Map<String, ExposedThing> _things = {};
  final Set<ConsumedThing> _consumedThings = {};

  final ServerSecurityCallback? _serverSecurityCallback;

  @override
  List<DiscoveryConfiguration> discoveryConfigurations;

  /// The [ContentSerdes] object that is used for serializing/deserializing.
  final ContentSerdes contentSerdes;

  @override
  Future<WoT> start() async {
    final serverStatuses = _servers
        .map((server) => server.start(_serverSecurityCallback))
        .toList(growable: false);

    for (final clientFactory in _clientFactories.values) {
      clientFactory.init();
    }

    await Future.wait(serverStatuses);
    return WoT(this);
  }

  @override
  Future<void> shutdown() async {
    for (final clientFactory in _clientFactories.values) {
      clientFactory.destroy();
    }
    _clientFactories.clear();
    for (final consumedThing in _consumedThings) {
      consumedThing.destroy();
    }
    _consumedThings.clear();

    final serverStatuses = _servers.map((server) => server.stop()).toList();
    await Future.wait(serverStatuses);
    serverStatuses.clear();
  }

  void _cleanUpForms(Iterable<InteractionAffordance>? interactionAffordances) {
    if (interactionAffordances == null) {
      return;
    }
    for (final interactionAffordance in interactionAffordances) {
      interactionAffordance.forms.clear();
    }
  }

  /// Exposes a [thing] so that WoT consumers can interact with it.
  Future<void> expose(ExposedThing thing) async {
    if (_servers.isEmpty) {
      return;
    }

    [thing.properties?.values, thing.actions?.values, thing.events?.values]
        .forEach(_cleanUpForms);

    final List<Future<void>> serverPromises = [];
    for (final server in _servers) {
      serverPromises.add(server.expose(thing));
    }

    await Future.wait(serverPromises);
  }

  /// Adds a [ExposedThing] to the servient if it hasn't been registered before.
  ///
  /// Returns `false` if the [thing] has already been registered, otherwise
  /// `true`.
  bool addThing(ExposedThing thing) {
    final id = thing.thingDescription.identifier;
    if (_things.containsKey(id)) {
      return false;
    }

    _things[id] = thing;
    return true;
  }

  /// Removes and cleans up the resources of a [ConsumedThing].
  ///
  /// If the [ConsumedThing] has not been registered before, `false` is
  /// returned, otherwise `true`.
  bool destroyConsumedThing(ConsumedThing consumedThing) {
    return consumedThing.destroy(external: false);
  }

  /// De-registers the given [consumedThing].
  ///
  /// If the [ConsumedThing] has not been registered before, `false` is
  /// returned, otherwise `true`.
  bool deregisterConsumedThing(ConsumedThing consumedThing) {
    return _consumedThings.remove(consumedThing);
  }

  /// Adds a [ConsumedThing] to the servient if it hasn't been registered
  /// before.
  ///
  /// Returns `false` if the [thing] has already been registered, otherwise
  /// `true`.
  bool addConsumedThing(ConsumedThing thing) => _consumedThings.add(thing);

  /// Returns an [ExposedThing] with the given [id] if it has been registered.
  ExposedThing? thing(String id) => _things[id];

  /// Returns a [Map] with the [ThingDescription]s of all registered
  /// [ExposedThing]s.
  Map<String, ThingDescription> get thingDescriptions {
    return _things.map((key, value) => MapEntry(key, value.thingDescription));
  }

  /// Returns a list of available [ProtocolServer]s.
  List<ProtocolServer> get servers => _servers;

  /// Registers a new [ProtocolServer].
  void addServer(ProtocolServer server) {
    _things.values.forEach(server.expose);

    _servers.add(server);
  }

  /// Returns a list of all protocol schemes the registered clients support.
  List<String> get clientSchemes =>
      _clientFactories.keys.toList(growable: false);

  @override
  void addClientFactory(ProtocolClientFactory clientFactory) {
    for (final scheme in clientFactory.schemes) {
      _clientFactories[scheme] = clientFactory;
    }
  }

  @override
  ProtocolClientFactory? removeClientFactory(String scheme) =>
      _clientFactories.remove(scheme);

  /// Returns the [ProtocolClient] associated with a given [scheme].
  ProtocolClient clientFor(String scheme) {
    final clientFactory = _clientFactories[scheme];

    if (clientFactory == null) {
      throw DartWotException(
        "Servient has no ClientFactory for scheme $scheme",
      );
    }

    return clientFactory.createClient();
  }

  /// Indicates whether there is a registered [ProtocolClientFactory] supporting
  /// the given [operationType] and [subprotocol].
  ///
  /// Also returns `false` if there is no [ProtocolClientFactory] registered for
  /// the given [scheme].
  @experimental
  bool supportsOperation(
    String scheme,
    OperationType operationType,
    String? subprotocol,
  ) {
    final protocolClient = _clientFactories[scheme];

    if (protocolClient == null) {
      return false;
    }

    return protocolClient.supportsOperation(operationType, subprotocol);
  }

  /// Consumes a [ThingDescription] and returns a [scripting_api.ConsumedThing].
  Future<scripting_api.ConsumedThing> consume(
    ThingDescription thingDescription,
  ) async {
    final newThing = ConsumedThing(this, thingDescription);
    addConsumedThing(newThing);

    return newThing;
  }

  /// Exposes a Thing based on an [scripting_api.ExposedThingInit].
  Future<scripting_api.ExposedThing> produce(
    scripting_api.ExposedThingInit init,
  ) async {
    const uuid = Uuid();

    final exposedThingInit = {
      "id": "urn:uuid:${uuid.v4()}",
      ...init,
    };

    final newThing = ExposedThing(this, exposedThingInit);
    if (addThing(newThing)) {
      return newThing;
    } else {
      final id = newThing.thingDescription.identifier;
      throw DartWotException(
        "A ConsumedThing with identifier $id already exists.",
      );
    }
  }

  /// Perform automatic discovery using this [InternalServient]'s
  /// [discoveryConfigurations].
  ///
  /// A [thingFilter] can be provided to filter the discovered Thing
  /// Descriptions; however, doing so currently does not have any effect yet.
  ThingDiscovery discover({
    scripting_api.ThingFilter? thingFilter,
  }) {
    return ThingDiscovery(thingFilter, this);
  }

  /// Requests a [ThingDescription] from a [url].
  Future<ThingDescription> requestThingDescription(Uri url) async {
    final client = clientFor(url.scheme);
    final content = await client.requestThingDescription(url);

    final dataSchemaValue = await contentSerdes.contentToValue(content, null);

    if (dataSchemaValue
        is! scripting_api.DataSchemaValue<Map<String, Object?>>) {
      throw DiscoveryException(
        "Could not parse Thing Description obtained from $url",
      );
    }

    return ThingDescription.fromJson(dataSchemaValue.value);
  }

  /// Retrieves [ThingDescription] from a Thing Description Directory (TDD).
  ///
  /// This method expects the TDD's Thing Description to be located under the
  /// provided [url] (e.g., https://example.org/.well-known/wot).
  /// Optionally, a [thingFilter] can be provided that is supposed to be used
  /// as part of the query issues to the TDD; however, providing the filter
  /// has no effect at the moment.
  ///
  /// Corresponding with the [API] specified in the
  /// [WoT Discovery Recommendation], it possible to specify an [offset] and
  /// a limit for the Thing Descriptions that are supposed to be returned from
  /// the TDD.
  /// The [format] is also configurable, however, only
  /// [scripting_api.DirectoryPayloadFormat.array] is supported at the moment.
  ///
  /// [API]: https://www.w3.org/TR/wot-discovery/#exploration-directory-api
  /// [WoT Discovery Recommendation]: https://www.w3.org/TR/wot-discovery
  Future<scripting_api.ThingDiscoveryProcess> exploreDirectory(
    Uri url, {
    scripting_api.ThingFilter? thingFilter,
    int? offset,
    int? limit,
    scripting_api.DirectoryPayloadFormat? format,
  }) async {
    // TODO(JKRhb): Add support for the collection format.
    if (format == scripting_api.DirectoryPayloadFormat.collection) {
      throw ArgumentError('Format "$format" is currently not supported.');
    }

    final thingDescription = await requestThingDescription(url);

    if (!thingDescription.isValidDirectoryThingDescription) {
      throw const DiscoveryException(
        "Encountered an invalid Directory Thing Description",
      );
    }

    final consumedDirectoryThing = await consume(thingDescription);

    final interactionOutput = await consumedDirectoryThing.readProperty(
      "things",
      uriVariables: {
        if (offset != null) "offset": offset,
        if (limit != null) "limit": limit,
        if (format != null) "format": format.toString(),
      },
    );
    final rawThingDescriptions = await interactionOutput.value();

    if (rawThingDescriptions is! List<Object?>) {
      throw const DiscoveryException(
        "Expected an array of Thing Descriptions but received an "
        "invalid output instead.",
      );
    }

    final thingDescriptionStream = Stream.fromIterable(
      rawThingDescriptions.whereType<Map<String, Object?>>(),
    ).map((rawThingDescription) => rawThingDescription.toThingDescription());

    return ThingDiscoveryProcess(thingDescriptionStream, thingFilter);
  }
}

extension _DirectoryValidationExtension on ThingDescription {
  bool get isValidDirectoryThingDescription {
    final atTypes = atType;

    if (atTypes == null) {
      return false;
    }

    const discoveryContextUri = "https://www.w3.org/2022/wot/discovery";
    const type = "ThingDirectory";
    const fullIri = "$discoveryContextUri#$type";

    if (atTypes.contains(fullIri)) {
      return true;
    }

    return context.contextEntries
            .contains(SingleContextEntry.fromString(discoveryContextUri)) &&
        atTypes.contains(type);
  }
}
