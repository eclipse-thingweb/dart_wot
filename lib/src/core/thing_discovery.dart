// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:async';

import '../../scripting_api.dart' as scripting_api;
import '../definitions/form.dart';
import '../definitions/interaction_affordances/property.dart';
import '../definitions/thing_description.dart';
import 'servient.dart';

/// Custom [Exception] that is thrown when the discovery process fails.
class DiscoveryError implements Exception {
  /// The error message of this exception.
  final String message;

  /// Creates a new [DiscoveryError] with the specified error [message].
  DiscoveryError(this.message);
}

/// Implemention of the [scripting_api.ThingDiscovery] interface.
class ThingDiscovery implements scripting_api.ThingDiscovery {
  bool _active = false;

  @override
  bool get active => _active;

  bool _done = false;

  @override
  bool get done => _done;

  Exception? _error;

  @override
  Exception? get error => _error;

  @override
  scripting_api.ThingFilter? thingFilter;

  final Servient _servient;

  // This linting issue should be a false positive.
  // ignore: close_sinks
  StreamController<ThingDescription>? _controller;

  StreamIterator<ThingDescription>? _streamIterator;

  /// Creates a new [ThingDiscovery] object with a given [thingFilter].
  ThingDiscovery(this.thingFilter, this._servient);

  @override
  Future<void> start() async {
    final thingFilter = this.thingFilter;
    _controller = StreamController();
    _streamIterator = StreamIterator(_controller!.stream);

    if (thingFilter == null) {
      // TODO(JKRhb): This has to be revisited once the specification has been
      //              updated and the thingFilter can actually be unset.
      throw ArgumentError("thingFilter can't be null!");
    }
    _active = true;

    final discoveryMethod = thingFilter.method;

    switch (discoveryMethod) {
      case scripting_api.DiscoveryMethod.direct:
        await _discoverDirectly(thingFilter.url);
        break;
      default:
        throw UnimplementedError();
    }
  }

  @override
  void stop() {
    _controller?.sink.close();
    _active = false;
  }

  Future<void> _discoverDirectly(String? uri) async {
    final controller = _controller;
    if (controller == null) {
      throw StateError("ThingDiscovery is not active!");
    }
    if (uri == null) {
      throw ArgumentError();
    }
    final parsedUri = Uri.parse(uri);
    final client = _servient.clientFor(parsedUri.scheme);
    // TODO(JKRhb): Get rid of this workaround
    final thingDescription = ThingDescription(null);
    final property = Property([], thingDescription);
    final fetchForm =
        Form(parsedUri, property, contentType: "application/td+json");

    final content = await client.readResource(fetchForm);
    await client.stop();

    final value = await _servient.contentSerdes.contentToValue(content, null);

    if (value is Map<String, dynamic>) {
      final thingDescription = ThingDescription.fromJson(value);
      _done = true; // TODO(JKRhb): Check if done should be set here
      _active = false;
      controller.sink.add(thingDescription);
      await controller.sink.close();
      return;
    }

    _error = DiscoveryError("Fetching Thing Description from $uri failed.");
    _active = false;
    _done = true;
    final error = _error;
    if (error is Exception) {
      throw error;
    }
  }

  @override
  Future<ThingDescription> next() async {
    final streamIterator = _streamIterator;
    if (streamIterator == null) {
      throw StateError("ThingDiscovery has not been started yet!");
    }
    final hasNext = await streamIterator.moveNext();
    if (!active && !hasNext) {
      _done = true;
    } else if (hasNext) {
      return streamIterator.current;
    }
    // TODO(JKRhb): Revisit error message
    throw StateError("ThingDiscovery has already been stopped!");
  }
}
