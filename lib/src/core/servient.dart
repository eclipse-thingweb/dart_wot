// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:uuid/uuid.dart';

import '../definitions/interaction_affordances/interaction_affordance.dart';
import '../definitions/thing_description.dart';
import 'consumed_thing.dart';
import 'content_serdes.dart';
import 'exposed_thing.dart';
import 'protocol_interfaces/protocol_client.dart';
import 'protocol_interfaces/protocol_client_factory.dart';
import 'protocol_interfaces/protocol_server.dart';
import 'security_provider.dart';
import 'wot.dart';

/// Exception that is thrown by a [Servient].
class ServientException implements Exception {
  /// Constructor
  ServientException(this._message);

  final String _message;

  @override
  String toString() => 'ServientException: $_message';
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
  /// A custom [contentSerdes] can be passed that supports other media types
  /// than the default ones.
  Servient({
    ClientSecurityProvider? clientSecurityProvider,
    ServerSecurityCallback? serverSecurityCallback,
    ContentSerdes? contentSerdes,
  })  : contentSerdes = contentSerdes ?? ContentSerdes(),
        _clientSecurityProvider = clientSecurityProvider,
        _serverSecurityCallback = serverSecurityCallback;

  final List<ProtocolServer> _servers = [];
  final Map<String, ProtocolClientFactory> _clientFactories = {};
  final Map<String, ExposedThing> _things = {};
  final Map<String, ConsumedThing> _consumedThings = {};

  final ClientSecurityProvider? _clientSecurityProvider;

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
    const uuid = Uuid();
    thing.id ??= 'urn:uuid:${uuid.v4()}';

    if (_things.containsKey(thing.id)) {
      return false;
    }

    _things[thing.id!] = thing;
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

  /// Adds a new [clientFactory] to this [Servient.]
  void addClientFactory(ProtocolClientFactory clientFactory) {
    for (final scheme in clientFactory.schemes) {
      _clientFactories[scheme] = clientFactory;
    }
  }

  /// Checks whether a [ProtocolClient] is avaiable for a given [scheme].
  bool hasClientFor(String scheme) => _clientFactories.containsKey(scheme);

  /// Returns the [ProtocolClient] associated with a given [scheme].
  ProtocolClient clientFor(String scheme) {
    if (hasClientFor(scheme)) {
      return _clientFactories[scheme]!.createClient(_clientSecurityProvider);
    } else {
      throw ServientException(
        'Servient has no ClientFactory for scheme $scheme',
      );
    }
  }
}
