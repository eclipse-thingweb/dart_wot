import 'package:coap/coap.dart';

/// Parses a [String] containing [encodedLinks] in the CoRE Link Format (RFC
/// 6690) and returns an [Iterable] of [Uri]s, which can be used for direct
/// discovery.
///
/// If the [Uri]s contained in the [encodedLinks] are relative, they are turned
/// into absolute [Uri]s using the original [discoveryUri] as a basis.
Iterable<Uri> parseCoreLinkFormat(String encodedLinks, Uri discoveryUri) {
  return CoapLinkFormat.parse(encodedLinks)
      .where(
    (link) =>
        // TODO(JKRhb): Resource Types need to contain " characters at the
        //              moment.
        //              IMHO this is a bug in the CoAP library that should be
        //              fixed.
        link.attributes.getResourceTypes()?.contains('"wot.thing"') ?? false,
  )
      .map((link) {
    final uri = Uri.tryParse(link.uri);
    if (uri == null) {
      return null;
    }

    final host = uri.host.isNotEmpty ? uri.host : discoveryUri.host;
    final scheme = uri.scheme.isNotEmpty ? uri.scheme : discoveryUri.scheme;
    final port = uri.port != 0 ? uri.port : discoveryUri.port;

    return uri.replace(host: host, scheme: scheme, port: port);
  }).whereType<Uri>();
}

/// Turn a [uri] into one usable for Thing Description Discovery with the CoRE
/// Link Format (RFC 6690).
///
/// Replaces the query parameters of the [uri] with `rt=wot.thing`, as specified
/// by the [WoT Disovery Specification].
///
/// [WoT Disovery Specification]: https://w3c.github.io/wot-discovery/#introduction-core-rd
Uri createCoreLinkFormatDiscoveryUri(Uri uri) {
  return uri.replace(queryParameters: <String, dynamic>{'rt': 'wot.thing'});
}
