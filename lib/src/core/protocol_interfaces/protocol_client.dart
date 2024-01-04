// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "../../scripting_api/subscription.dart";
import "../augmented_form.dart";
import "../content.dart";

/// Base class for a Protocol Client.
abstract interface class ProtocolClient {
  /// Starts this [ProtocolClient].
  Future<void> start();

  /// Stops this [ProtocolClient].
  Future<void> stop();

  /// Discovers one or more Thing Descriptions from a [uri], returning a
  /// [Stream] of [Content].
  ///
  /// Allows the caller to explicitly [disableMulticast], overriding the
  /// multicast settings in the config of the underlying binding implementation.
  Stream<DiscoveryContent> discoverDirectly(
    Uri uri, {
    bool disableMulticast = false,
  });

  /// Discovers links using the CoRE Link Format (see [RFC 6690]) from a [uri],
  /// encoded as a [Stream] of [Content].
  ///
  /// This method will also be used for discovery from CoRE Resource
  /// Directories ([RFC 9176]).
  ///
  /// If the [uri]'s path is empty, then `/.well-known/core` will be set as a
  /// default value.
  ///
  /// Certain protocols (like CoAP) might also use multicast for this discovery
  /// method if the underlying binding implementation supports it and if it is
  /// activated in the config.
  ///
  /// [RFC 6690]: https://datatracker.ietf.org/doc/html/rfc6690
  /// [RFC 9176]: https://datatracker.ietf.org/doc/html/rfc9176
  Stream<DiscoveryContent> discoverWithCoreLinkFormat(Uri uri);

  /// Requests the client to perform a `readproperty` operation on a [form].
  Future<Content> readResource(AugmentedForm form);

  /// Requests the client to perform a `writeproperty` operation on a [form]
  /// using the given [content].
  Future<void> writeResource(AugmentedForm form, Content content);

  /// Requests the client to perform an `invokeaction` operation on a [form]
  /// using the given [content].
  Future<Content> invokeResource(AugmentedForm form, Content content);

  /// Requests the client to perform a `subscribeproperty` operation on a
  /// [form].
  Future<Subscription> subscribeResource(
    AugmentedForm form, {
    required void Function(Content content) next,
    void Function(Exception error)? error,
    required void Function() complete,
  });

  /// Requests a Thing Description as [Content] from a [url].
  Future<Content> requestThingDescription(Uri url);
}
