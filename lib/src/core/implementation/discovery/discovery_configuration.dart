// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:meta/meta.dart";

import "../../scripting_api/discovery/thing_filter.dart";

/// Used to indicate whether the discovery mechanism will be used to discover
/// Thing Descriptions of Things or Thing Description Directories.
enum DiscoveryType {
  /// Indicates that the discovery mechanism will discover Thing Descriptions of
  /// Things.
  thing(
    coreLinkFormatResourceType: "wot.thing",
    dnsDsType: "Thing",
  ),

  /// Indicates that the discovery mechanism will discover Thing Descriptions of
  /// Thing Description Directories.
  directory(
    coreLinkFormatResourceType: "wot.directory",
    dnsDsType: "Directory",
  ),
  ;

  const DiscoveryType({
    required this.coreLinkFormatResourceType,
    required this.dnsDsType,
  });

  /// The Core Link Format ([RFC 6690]) resource type that is used for this
  /// type of discovery mechanism
  ///
  /// See [section 6.4] of the [WoT Discovery specification] for more
  /// information.
  ///
  /// [RFC 6690]: https://datatracker.ietf.org/doc/html/rfc6690
  /// [section 6.4]: https://www.w3.org/TR/wot-discovery/#introduction-core-rd-sec
  /// [WoT Discovery specification]: https://www.w3.org/TR/wot-discovery
  final String coreLinkFormatResourceType;

  /// The value for "type" that is used for this discovery variant in TXT
  /// records obtained during DNS-based service discovery.
  ///
  /// See [section 6.3] of the [WoT Discovery specification] for more
  /// information.
  ///
  /// [RFC 6690]: https://datatracker.ietf.org/doc/html/rfc6690
  /// [section 6.3]: https://www.w3.org/TR/wot-discovery/#introduction-dns-sd-sec
  /// [WoT Discovery specification]: https://www.w3.org/TR/wot-discovery
  final String dnsDsType;
}

/// The protocol type that is used for DNS-based service discovery.
enum ProtocolType {
  /// Indicates that services that use TCP-based protocols like HTTP for
  /// exposing their Thing Description shall be discovered.
  tcp(
    defaultDnsSdUriScheme: "http",
    dnsSdProtocolLabel: "_tcp",
  ),

  /// Indicates that services that use UDP-based protocols like CoAP for
  /// exposing their Thing Description shall be discovered.
  udp(
    defaultDnsSdUriScheme: "coap",
    dnsSdProtocolLabel: "_udp",
  ),
  ;

  const ProtocolType({
    required this.defaultDnsSdUriScheme,
    required this.dnsSdProtocolLabel,
  });

  /// The default URI scheme that is used for this protocol.
  ///
  /// For [ProtocolType.tcp], this is defined as `http`, and for
  /// [ProtocolType.udp] it is defined as `coap`.
  final String defaultDnsSdUriScheme;

  /// The subdomain for this protocol variant.
  ///
  /// Results in `_tcp` for [ProtocolType.tcp] and `_udp` for
  /// [ProtocolType.udp].
  final String dnsSdProtocolLabel;
}

/// A configuration that is used by the `WoT.discover()` method when registered
/// with the underlying `Servient`.
@immutable
sealed class DiscoveryConfiguration {
  const DiscoveryConfiguration();
}

/// A configuration used for direct discovery, i.e. the direct retrieval of a
/// Thing Description from a [uri].
final class DirectConfiguration extends DiscoveryConfiguration {
  /// Instantiates a new [DirectConfiguration] object from a [uri].
  const DirectConfiguration(this.uri);

  /// The [Uri] the Thing Description can be retrieved from.
  final Uri uri;
}

/// A configuration that is used for retrieving Thing Descriptions from a Thing
/// Description Directory (TDD).
final class ExploreDirectoryConfiguration extends DiscoveryConfiguration {
  /// Instantiates a new [ExploreDirectoryConfiguration].
  ///
  /// The [uri] needs to point to the Thing Description exposed by the TDD that
  /// is supposed to be used for this [DiscoveryConfiguration].
  ///
  /// A [thingFilter] can be provided for filtering and the total number of TDs
  /// can be [limit]ed.
  const ExploreDirectoryConfiguration(
    this.uri, {
    this.thingFilter,
    this.limit,
  });

  /// The [Uri] the TDD's Thing Description can be retrieved from.
  final Uri uri;

  /// Optional filter that is supposed to used as a query parameter and
  /// to filter received TDs.
  ///
  /// Currently, this configuration parameter is unused, however.
  final ThingFilter? thingFilter;

  /// The maximum number of TDs that should be returned by the Thing Description
  /// Directory.
  ///
  /// Note that, currently, this limit is not being enforced at the client side.
  final int? limit;
}

/// Experimental [DiscoveryConfiguration] that is used to perform discovery with
/// the MQTT protocol.
@experimental
final class MqttDiscoveryConfiguration extends DiscoveryConfiguration {
  /// Instantiates a new [DiscoveryConfiguration] for MQTT.
  const MqttDiscoveryConfiguration(
    this.brokerUri, {
    this.discoveryTopic = "wot/td/#",
    this.expectedContentType = "application/td+json",
    this.discoveryTimeout = const Duration(seconds: 5),
  });

  /// [Uri] of the broker the
  final Uri brokerUri;

  /// The topic that will be used for performing the discovery process.
  ///
  /// If a wildcard topic is used, then the discovery process may return more
  /// than one TD.
  ///
  /// Defaults to `wot/td/#`.
  final String discoveryTopic;

  /// The Thing Description content type that is expected during the discovery
  /// process.
  ///
  /// Data that is received during the discovery process that is not
  /// deserializable using the content type provided here will be ignored.
  ///
  /// Defaults to `application/td+json`.
  final String expectedContentType;

  /// Time period after which the MQTT discovery process is going to be
  /// cancelled.
  ///
  /// Defaults to five seconds.
  final Duration discoveryTimeout;
}

/// Base class for configuring discovery mechanisms that involve a two-step
/// approach.
///
/// These mechanisms first discover URLs pointing to Thing Descriptions
/// (introduction phase) before retrieving the Thing Descriptions themselves
/// (exploration phase).
sealed class TwoStepConfiguration extends DiscoveryConfiguration {
  /// Creates a new [TwoStepConfiguration] object from a [discoveryType].
  const TwoStepConfiguration({required this.discoveryType});

  /// Indicates whether this configuration is used for discovering Things or
  /// Thing Description Directories.
  final DiscoveryType discoveryType;
}

/// A [DiscoveryConfiguration] for performing DNS-based Service Discovery
/// ([RFC 6763]) to obtain Thing Descriptions.
///
/// [RFC 6763]: https://datatracker.ietf.org/doc/html/rfc6763
final class DnsSdDConfiguration extends TwoStepConfiguration {
  /// Instantiates a new [DnsSdDConfiguration], indicating the [protocolType]
  /// and [discoveryType].
  ///
  /// By default, `.local` (for multicast DNS, [RFC 6762]) will be used as the
  /// configuration's [domainName].
  /// Other domain names are currently unsupported.
  ///
  /// [RFC 6762]: https://datatracker.ietf.org/doc/html/rfc6762
  const DnsSdDConfiguration({
    this.domainName = ".local",
    super.discoveryType = DiscoveryType.thing,
    this.protocolType = ProtocolType.tcp,
  });

  /// The domain name that will be used for DNS-based Service Discovery.
  ///
  /// By default, `.local` will be used as the domain name, indicating that
  /// multicast DNS (RFC 6764) will be used for performing the discovery.
  ///
  /// Other domain names (and therefore unicast DNS) are currently unsupported.
  ///
  /// [RFC 6762]: https://datatracker.ietf.org/doc/html/rfc6762
  final String domainName;

  /// Indicates whether TCP-based or a UDP-based WoT services be will be
  /// discovered.
  final ProtocolType protocolType;
}

/// Configures discovery using the CoRE link format ([RFC 6690]).
///
/// [RFC 6690]: https://datatracker.ietf.org/doc/html/rfc6690
final class CoreLinkFormatConfiguration extends TwoStepConfiguration {
  /// Instantiates a new [CoreLinkFormatConfiguration] object.
  ///
  /// The [baseUrl] can either be a unicast or – when using a multicast-capable
  /// protocol such as CoAP – a multicast [Uri]. The default URI path used for
  /// discovering Thing Descriptions is the standardized `/.well-known/core`
  /// (see [RFC 6690, section 4]).
  ///
  /// By default, the discovery process used with this configuration will try
  /// to obtain Thing Descriptions for Things, as indicated by the
  /// [discoveryType].
  ///
  /// [RFC 6690, section 4]: https://datatracker.ietf.org/doc/html/rfc6690#section-4
  CoreLinkFormatConfiguration(
    Uri baseUrl, {
    super.discoveryType = DiscoveryType.thing,
    String coreLinkFormatPath = "/.well-known/core",
  }) : uri = baseUrl.replace(
          path: coreLinkFormatPath,
          queryParameters: {
            "rt": discoveryType.coreLinkFormatResourceType,
          },
        );

  /// Points to the CoRE Link Format resource.
  ///
  /// By default, this [Uri] will the well-known URI path `/.well-known/core` as
  /// described in [RFC 6690, section 4].
  ///
  /// [RFC 6690, section 4]: https://datatracker.ietf.org/doc/html/rfc6690#section-4
  final Uri uri;
}

/// A configuration for performing discovery using a CoRE Resource Directory
/// ([RFC 9176]).
///
/// Using this [DiscoveryConfiguration], the underlying platform will first try
/// to obtain a link to one or (when using multicast) more CoRE Resource
/// Directory lookup interfaces.
/// Then it will use these interfaces to obtain links that point to Thing
/// Description resources and, as last step, try to retrieve the Thing
/// Descriptions themselves.
///
/// [RFC 9176]: https://datatracker.ietf.org/doc/html/rfc9176
final class CoreResourceDirectoryConfiguration extends TwoStepConfiguration {
  /// Instantiates a new [CoreResourceDirectoryConfiguration] object.
  ///
  /// The [baseUrl] can either be a unicast or – when using a multicast-capable
  /// protocol such as CoAP – a multicast [Uri]. The default URI path used for
  /// discovering lookup interfaces of CoRE Resource Directories is the
  /// standardized URI path `/.well-known/core` (see [RFC 6690, section 4]).
  ///
  /// By default, the discovery process used with this configuration will try
  /// to obtain Thing Descriptions for Things, as indicated by the
  /// [discoveryType].
  ///
  /// [RFC 6690, section 4]: https://datatracker.ietf.org/doc/html/rfc6690#section-4
  CoreResourceDirectoryConfiguration(
    Uri baseUrl, {
    super.discoveryType = DiscoveryType.thing,
    String coreLinkFormatPath = "/.well-known/core",
  }) : uri = baseUrl.replace(
          path: coreLinkFormatPath,
          queryParameters: {
            "rt": "core.rd-lookup-res",
          },
        );

  /// A [Uri] pointing to the resource where a directory's CoRE Link Format
  /// links can be retrieved.
  ///
  /// By default, the standardized URI path `/.well-known/core` will be used
  /// (see [RFC 6690, section 4]).
  ///
  /// [RFC 6690, section 4]: https://datatracker.ietf.org/doc/html/rfc6690#section-4
  final Uri uri;
}
