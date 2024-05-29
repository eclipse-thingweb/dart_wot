import "package:meta/meta.dart";

import "../implementation/content.dart";
import "protocol_client.dart";

/// Interface for a client that is able to [discoverDirectly], i.e. to retrieve
/// a Thing Description from a given [Uri] via unicast.
base mixin DirectDiscoverer on ProtocolClient {
  /// Discovers one Thing Descriptions from a [uri], returning a
  /// [Future] of [Content].
  Future<Content> discoverDirectly(Uri uri);
}

/// Interface for a client that is able to [discoverViaMulticast], i.e. to
/// retrieve a [Stream] of Thing Descriptions from a given [Uri] via multicast.
base mixin MulticastDiscoverer on ProtocolClient {
  /// Discovers a [Stream] Thing Descriptions from a [uri], returning a
  /// [Stream] of [Content].
  ///
  /// The host component of the [uri] has to be a multicast IP address, while
  /// the protocol referenced by its [Uri.scheme] has to indicate that the
  /// protocol itself also supports multicast.
  /// Otherwise, an exception will be thrown.
  Stream<Content> discoverViaMulticast(Uri uri);
}

/// Interfaces for clients that support discovery via the CoRE Link Format.
@experimental
base mixin CoreLinkFormatDiscoverer on ProtocolClient {
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
  @experimental
  Stream<DiscoveryContent> discoverWithCoreLinkFormat(Uri uri);
}
