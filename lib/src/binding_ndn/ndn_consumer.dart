// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dart_ndn/dart_ndn.dart";
import "package:meta/meta.dart";

import "../../core.dart";
import "ndn_config.dart";

/// A WoT [ProtocolClient] acting as an NDN consumer.
@immutable
class NdnClient implements ProtocolClient {
  /// Creates a new [NdnClient] from an NDN [_consumer].
  const NdnClient(this._consumer);

  /// Asynchronously creates a new [NdnClient] from an [NdnConfig].
  static Future<NdnClient> create(NdnConfig config) async {
    final consumer = await Consumer.create(config.faceUri);
    return NdnClient(consumer);
  }

  final Consumer _consumer;

  @override
  Stream<DiscoveryContent> discoverDirectly(
    Uri uri, {
    bool disableMulticast = false,
  }) {
    // TODO: implement discoverDirectly
    throw UnimplementedError();
  }

  @override
  Stream<DiscoveryContent> discoverWithCoreLinkFormat(Uri uri) {
    // TODO: implement discoverWithCoreLinkFormat
    throw UnimplementedError();
  }

  @override
  Future<Content> invokeResource(AugmentedForm form, Content content) {
    // TODO: implement invokeResource
    throw UnimplementedError();
  }

  @override
  Future<Content> readResource(AugmentedForm form) async {
    // TODO: Add Name.fromUri
    final name = Name.fromString(form.href.path);

    final result = await _consumer.expressInterest(name);

    switch (result) {
      case DataReceived(:final data):
        final iterable = [data.content ?? <int>[]];

        return Content(form.contentType, Stream.fromIterable(iterable));
      default:
        throw Exception("TODO");
    }
  }

  @override
  Future<Content> requestThingDescription(Uri url) {
    // TODO: implement requestThingDescription
    throw UnimplementedError();
  }

  @override
  Future<void> stop() async {
    await _consumer.shutdown();
  }

  @override
  Future<Subscription> subscribeResource(
    AugmentedForm form, {
    required void Function(Content content) next,
    void Function(Exception error)? error,
    required void Function() complete,
  }) {
    // TODO: implement subscribeResource
    throw UnimplementedError();
  }

  @override
  Future<void> writeResource(AugmentedForm form, Content content) {
    // TODO: implement writeResource
    throw UnimplementedError();
  }
}
