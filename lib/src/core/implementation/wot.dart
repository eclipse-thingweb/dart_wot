// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:async";

import "package:uuid/uuid.dart";

import "../definitions.dart";
import "../exceptions.dart";
import "../scripting_api.dart" as scripting_api;
import "consumed_thing.dart";
import "exposed_thing.dart";
import "servient.dart";
import "thing_discovery.dart";

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
      throw DartWotException(id);
    }
  }

  /// Exposes a Thing based on a (partial) TD.
  @override
  Future<scripting_api.ExposedThing> produce(
    Map<String, dynamic> init,
  ) async {
    const uuid = Uuid();

    final exposedThingInit = {
      "id": "urn:uuid:${uuid.v4()}",
      ...init,
    };

    final newThing = ExposedThing(_servient, exposedThingInit);
    if (_servient.addThing(newThing)) {
      return newThing;
    } else {
      final id = newThing.thingDescription.identifier;
      throw DartWotException(
        "A ConsumedThing with identifier $id already exists.",
      );
    }
  }

  @override
  ThingDiscovery discover(
    Uri url, {
    scripting_api.ThingFilter? thingFilter,
    scripting_api.DiscoveryMethod method = scripting_api.DiscoveryMethod.direct,
  }) {
    return ThingDiscovery(url, thingFilter, _servient, method: method);
  }

  @override
  Future<ThingDescription> requestThingDescription(Uri url) {
    return _servient.requestThingDescription(url);
  }

  @override
  Future<scripting_api.ThingDiscoveryProcess> exploreDirectory(
    Uri url, {
    scripting_api.ThingFilter? filter,
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

    return ThingDiscoveryProcess(thingDescriptionStream, filter);
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

    return context.contains((value: discoveryContextUri, key: null)) &&
        atTypes.contains(type);
  }
}
