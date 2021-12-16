// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import 'package:uuid/uuid.dart';

import '../../definitions.dart';
import '../definitions/interaction_affordances/interaction_affordance.dart';
import 'credentials.dart';
import 'exposed_thing.dart';
import 'protocol_interfaces/protocol_client.dart';
import 'protocol_interfaces/protocol_client_factory.dart';
import 'protocol_interfaces/protocol_server.dart';
import 'wot.dart';

///
class Servient {
  final List<ProtocolServer> _servers = [];
  final Map<String, ProtocolClientFactory> _clientFactories = {};
  final Map<String, ExposedThing> _things = {};
  final Map<String, Credentials> _credentialsStore = {};

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
    _clientFactories[clientFactory.scheme] = clientFactory;
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
  Credentials? credentials(String identifier) => _credentialsStore[identifier];
}
