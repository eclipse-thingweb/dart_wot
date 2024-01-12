// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:meta/meta.dart";

import "../definitions.dart";
import "../scripting_api.dart" as scripting_api;
import "consumed_thing.dart";
import "content_serdes.dart";
import "discovery_exception.dart";
import "exposed_thing.dart";
import "protocol_interfaces/protocol_client.dart";
import "protocol_interfaces/protocol_client_factory.dart";
import "protocol_interfaces/protocol_server.dart";
import "wot.dart";

/// Exception that is thrown by a [Servient].
class ServientException implements Exception {
  /// Constructor
  ServientException(this._message);

  final String _message;

  @override
  String toString() => "ServientException: $_message";
}

// TODO(JKRhb): Documentation should be improved.
/// A software stack that implements the WoT building blocks.
///
/// A [Servient] can host and expose Things and/or host Consumers that consume
/// Things. Servients can support multiple Protocol Bindings to enable
/// interaction with different IoT platforms.
class Servient {
  /// Creates a new [Servient].
  ///
  /// The [Servient] can be preconfigured with a [List] of
  /// [ProtocolClientFactory]s.
  /// However, it is also possible to dynamically [addClientFactory]s and
  /// [removeClientFactory]s at runtime.
  ///
  /// If you want to support a custom media type not already included in the
  /// [ContentSerdes] class, a custom [contentSerdes] object can be passed as an
  /// argument.
  Servient({
    List<ProtocolClientFactory>? clientFactories,
    ServerSecurityCallback? serverSecurityCallback,
    ContentSerdes? contentSerdes,
  })  : contentSerdes = contentSerdes ?? ContentSerdes(),
        _serverSecurityCallback = serverSecurityCallback {
    for (final clientFactory in clientFactories ?? <ProtocolClientFactory>[]) {
      addClientFactory(clientFactory);
    }
  }

  final List<ProtocolServer> _servers = [];
  final Map<String, ProtocolClientFactory> _clientFactories = {};
  final Map<String, ExposedThing> _things = {};
  final Map<String, ConsumedThing> _consumedThings = {};

  final ServerSecurityCallback? _serverSecurityCallback;

  /// The [ContentSerdes] object that is used for serializing/deserializing.
  final ContentSerdes contentSerdes;

  /// Starts this [Servient] and returns a [WoT] runtime object.
  ///
  /// The [WoT] runtime can be used for consuming, procuding, and discovering
  /// Things.
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

  /// Closes the client.
  Future<void> shutdown() async {
    for (final clientFactory in _clientFactories.values) {
      clientFactory.destroy();
    }
    _clientFactories.clear();
    for (final consumedThing in _consumedThings.values) {
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

  /// Removes and cleans up the resources of the [ConsumedThing] with the given
  /// [id].
  ///
  /// If the [ConsumedThing] has not been registered before, `false` is
  /// returned, otherwise `true`.
  bool destroyConsumedThing(String id) {
    final existingThing = _consumedThings.remove(id);

    if (existingThing != null) {
      existingThing.destroy();
      return true;
    }

    return false;
  }

  /// Adds a [ConsumedThing] to the servient if it hasn't been registered
  /// before.
  ///
  /// Returns `false` if the [thing] has already been registered, otherwise
  /// `true`.
  bool addConsumedThing(ConsumedThing thing) {
    final id = thing.identifier;
    if (_things.containsKey(id)) {
      return false;
    }

    _consumedThings[id] = thing;
    return true;
  }

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

  /// Adds a new [clientFactory] to this [Servient].
  void addClientFactory(ProtocolClientFactory clientFactory) {
    for (final scheme in clientFactory.schemes) {
      _clientFactories[scheme] = clientFactory;
    }
  }

  /// Removes a [ProtocolClientFactory] matching the given [scheme] from this
  /// [Servient], if present.
  ///
  /// If a [ProtocolClientFactory] was removed, the method returns it, otherwise
  /// the return value is `null`.
  ProtocolClientFactory? removeClientFactory(String scheme) =>
      _clientFactories.remove(scheme);

  /// Checks whether a [ProtocolClient] is avaiable for a given [scheme].
  bool hasClientFor(String scheme) => _clientFactories.containsKey(scheme);

  /// Returns the [ProtocolClient] associated with a given [scheme].
  ProtocolClient clientFor(String scheme) {
    final clientFactory = _clientFactories[scheme];

    if (clientFactory == null) {
      throw ServientException(
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
}
