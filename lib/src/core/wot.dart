// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:async';

import '../../scripting_api.dart' as scripting_api;
import '../definitions/thing_description.dart';
import '../scripting_api/discovery/discovery_method.dart';
import 'consumed_thing.dart';
import 'exposed_thing.dart';
import 'servient.dart';
import 'thing_discovery.dart'
    show DiscoveryException, ThingDiscovery, ThingDiscoveryProcess;

/// This [Exception] is thrown if an error during the consumption of a
/// [ThingDescription] occurs.
class ThingConsumptionException implements Exception {
  /// Constructor
  ThingConsumptionException(this.identifier);

  /// The identifier of the [ThingDescription] that triggered this [Exception].
  final String identifier;

  @override
  String toString() {
    return 'ThingConsumptionException: A ConsumedThing with identifier '
        '$identifier already exists.';
  }
}

/// This [Exception] is thrown if an error during the production of a
/// [ThingDescription] occurs.
class ThingProductionException implements Exception {
  /// Constructor
  ThingProductionException(this.identifier);

  /// The identifier of the [ThingDescription] that triggered this [Exception].
  final String identifier;

  @override
  String toString() {
    return 'ThingProductionException: An ExposedThing with identifier '
        '$identifier already exists.';
  }
}

/// Implementation of the [scripting_api.WoT] runtime interface.
class WoT implements scripting_api.WoT {
  /// Creates a new [WoT] runtime based on a [Servient].
  WoT(this._servient);

  final Servient _servient;

  /// Consumes a [ThingDescription] and returns a [scripting_api.ConsumedThing].
  ///
  /// The returned [ConsumedThing] can then be used to trigger
  /// interaction affordances exposed by the Thing.
  ///
  /// If a [ThingDescription] with the same identifier has already been
  @override
  Future<scripting_api.ConsumedThing> consume(
    ThingDescription thingDescription,
  ) async {
    final newThing = ConsumedThing(_servient, thingDescription);
    if (_servient.addConsumedThing(newThing)) {
      return newThing;
    } else {
      final id = thingDescription.identifier;
      throw ThingConsumptionException(id);
    }
  }

  /// Exposes a Thing based on a (partial) TD.
  @override
  Future<scripting_api.ExposedThing> produce(Map<String, dynamic> init) async {
    final newThing = ExposedThing(_servient, init);
    if (_servient.addThing(newThing)) {
      return newThing;
    } else {
      final id = newThing.thingDescription.identifier;
      throw ThingProductionException(id);
    }
  }

  @override
  ThingDiscovery discover(
    Uri url, {
    scripting_api.ThingFilter? thingFilter,
    DiscoveryMethod method = DiscoveryMethod.direct,
  }) {
    return ThingDiscovery(url, thingFilter, _servient, method: method);
  }

  @override
  Future<ThingDescription> requestThingDescription(Uri url) {
    return _servient.requestThingDescription(url);
  }

  @override
  Future<scripting_api.ThingDiscoveryProcess> exploreDirectory(
    Uri url, [
    scripting_api.ThingFilter? filter,
  ]) async {
    final thingDescription = await requestThingDescription(url);

    if (!thingDescription.isValidDirectoryThingDescription) {
      throw DiscoveryException(
        'Encountered an invalid Directory Thing Description',
      );
    }

    final consumedDirectoryThing = await consume(thingDescription);

    final interactionOutput =
        await consumedDirectoryThing.readProperty('things');
    final rawThingDescriptions = await interactionOutput.value();

    if (rawThingDescriptions is! List<Object?>) {
      throw DiscoveryException(
        'Expected an array of Thing Descriptions but received an '
        'invalid output instead.',
      );
    }

    final thingDescriptionStream = Stream.fromIterable(
      rawThingDescriptions.whereType<Map<String, Object?>>(),
    ).toThingDescriptionStream();

    return ThingDiscoveryProcess(thingDescriptionStream, filter);
  }
}

extension _DirectoryValidationExtension on ThingDescription {
  bool get isValidDirectoryThingDescription {
    final atTypes = atType;

    if (atTypes == null) {
      return false;
    }

    const discoveryContextUri = 'https://www.w3.org/2022/wot/discovery';
    const type = 'ThingDirectory';
    const fullIri = '$discoveryContextUri#$type';

    if (atTypes.contains(fullIri)) {
      return true;
    }

    return context.contains((value: discoveryContextUri, key: null)) &&
        atTypes.contains(type);
  }
}

extension _DirectoryTdDeserializationExtension on Stream<Map<String, Object?>> {
  Stream<ThingDescription> toThingDescriptionStream() {
    const streamTransformer = StreamTransformer(_transformerMethod);

    return transform(streamTransformer);
  }

  static StreamSubscription<ThingDescription> _transformerMethod(
    Stream<Map<String, dynamic>> rawThingDescriptionStream,
    bool cancelOnError,
  ) {
    final streamController = StreamController<ThingDescription>();

    final streamSubscription = rawThingDescriptionStream.listen(
      (rawThingDescription) {
        try {
          streamController.add(ThingDescription.fromJson(rawThingDescription));
        } on Exception catch (exception) {
          streamController.addError(exception);
        }
      },
      onDone: streamController.close,
      onError: streamController.addError,
      cancelOnError: cancelOnError,
    );

    streamController
      ..onPause = streamSubscription.pause
      ..onResume = streamSubscription.resume
      ..onCancel = streamSubscription.cancel;

    return streamController.stream.listen(null);
  }
}
