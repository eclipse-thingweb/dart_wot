// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import '../../scripting_api.dart' as scripting_api;
import '../definitions/form.dart';
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

  final scripting_api.DiscoveryListener _callback;

  /// Creates a new [ThingDiscovery] object with a given [thingFilter].
  ThingDiscovery(this._callback, this.thingFilter, this._servient);

  @override
  Future<void> start() async {
    final thingFilter = this.thingFilter;

    if (thingFilter == null) {
      throw ArgumentError();
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
    _active = false;
  }

  Future<void> _discoverDirectly(String? uri) async {
    if (uri == null) {
      throw ArgumentError();
    }
    final parsedUri = Uri.parse(uri);
    final client = _servient.clientFor(parsedUri.scheme);
    final fetchForm = Form(uri, "application/td+json");

    final content = await client.readResource(fetchForm);
    await client.stop();

    final value = await _servient.contentSerdes.contentToValue(content, null);

    if (value is Map<String, dynamic>) {
      _callback(ThingDescription.fromJson(value));
      _active = false;
      _done = true;
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
}
