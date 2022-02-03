// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:uuid/uuid.dart';

import '../definitions/credentials/credentials.dart';
import '../definitions/interaction_affordances/interaction_affordance.dart';
import '../definitions/thing_description.dart';
import 'content_serdes.dart';
import 'exposed_thing.dart';
import 'protocol_interfaces/protocol_client.dart';
import 'protocol_interfaces/protocol_client_factory.dart';
import 'protocol_interfaces/protocol_server.dart';
import 'wot.dart';

// TODO(JKRhb): Documentation should be improved.
/// A software stack that implements the WoT building blocks.
///
/// A [Servient] can host and expose Things and/or host Consumers that consume
/// Things. Servients can support multiple Protocol Bindings to enable
/// interaction with different IoT platforms.
class Servient {
  final List<ProtocolServer> _servers = [];
  final Map<String, ProtocolClientFactory> _clientFactories = {};
  final Map<String, ExposedThing> _things = {};
  final Map<String, Map<String, Credentials>> _credentialsStore = {};

  /// The [ContentSerdes] object that is used for serializing/deserializing.
  final ContentSerdes contentSerdes;

  /// Creates a new [Servient].
  ///
  /// A custom [contentSerdes] can be passed that supports other media types
  /// than the default ones.
  Servient([ContentSerdes? contentSerdes])
      : contentSerdes = contentSerdes ?? ContentSerdes();

  /// Starts this [Servient] and returns a [WoT] runtime object.
  ///
  /// The [WoT] runtime can be used for consuming, procuding, and discovering
  /// Things.
  Future<WoT> start() async {
    final serverStatuses = _servers
        .map((server) => server.start(_credentialsStore))
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

    final serverStatuses =
        _servers.map((server) => server.stop()).toList(growable: false);
    await Future.wait(serverStatuses);
  }

  void _cleanUpForms(Iterable<InteractionAffordance>? interactionAffordances) {
    if (interactionAffordances == null) {
      return;
    }
    for (final interactionAffordance in interactionAffordances) {
      interactionAffordance.forms = [];
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
    final uuid = Uuid();
    thing.id ??= 'urn:uuid:${uuid.v4()}';

    if (_things.containsKey(thing.id)) {
      return false;
    }

    _things[thing.id!] = thing;
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
    for (final thing in _things.values) {
      server.expose(thing);
    }

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

  /// Adds new [credentials] to this [Servient].
  void addCredentials(
      String id, String definitionKey, Credentials credentials) {
    final currentCredentials = _credentialsStore[id];
    if (currentCredentials == null) {
      _credentialsStore[id] = {definitionKey: credentials};
    } else {
      currentCredentials[definitionKey] = credentials;
    }
  }

  /// Removes [Credentials] from this [Servient].
  ///
  /// Returns the [Credentials] if the removal was successful, otherwise `null`.
  Credentials? removeCredentials(String id, String definitionKey) {
    return _credentialsStore[id]?.remove(definitionKey);
  }

  /// Checks whether a [ProtocolClient] is avaiable for a given [scheme].
  bool hasClientFor(String scheme) => _clientFactories.containsKey(scheme);

  /// Returns the [ProtocolClient] associated with a given [scheme].
  ProtocolClient clientFor(String scheme) {
    if (hasClientFor(scheme)) {
      return _clientFactories[scheme]!.createClient();
    } else {
      throw StateError('Servient has no ClientFactory for scheme $scheme');
    }
  }

  /// Returns the [Credentials] for a given [identifier].
  ///
  /// Returns null if the [identifier] is unknown.
  Map<String, Credentials>? credentials(String identifier) =>
      _credentialsStore[identifier];
}
