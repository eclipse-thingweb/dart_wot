// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:curie/curie.dart";
import "package:meta/meta.dart";

import "extensions/json_parser.dart";

/// Represents an element of the `links` array in a Thing Description.
///
/// A link can be viewed as a statement of the form "link context has a relation
/// type resource at link target", where the optional target attributes may
/// further describe the resource.
@immutable
class Link {
  /// Constructor.
  const Link(
    this.href, {
    this.type,
    this.rel,
    this.anchor,
    this.sizes,
    this.hreflang,
    this.additionalFields,
  });

  /// Creates a new [Link] from a [json] object.
  factory Link.fromJson(
    Map<String, dynamic> json,
    PrefixMapping prefixMapping,
  ) {
    final Set<String> parsedFields = {};

    final href = json.parseRequiredUriField("href", parsedFields);
    final type = json.parseField<String>("@type", parsedFields);
    final rel = json.parseField<String>("rel", parsedFields);
    final anchor = json.parseUriField("anchor", parsedFields);
    final sizes = json.parseField<String>("sizes", parsedFields);
    final hreflang = json.parseArrayField<String>("hreflang", parsedFields);
    final additionalFields =
        json.parseAdditionalFields(prefixMapping, parsedFields);

    return Link(
      href,
      type: type,
      rel: rel,
      anchor: anchor,
      sizes: sizes,
      hreflang: hreflang,
      additionalFields: additionalFields,
    );
  }

  /// Target IRI of a link or submission target of a form.
  final Uri href;

  /// Target attribute providing a hint indicating what the media type (see RFC
  /// 2046) of the result of dereferencing the link should be.
  final String? type;

  /// A link relation type identifies the semantics of a link.
  final String? rel;

  /// Overrides the link context (by default the Thing itself identified by its
  /// id) with the given URI or IRI.
  final Uri? anchor;

  /// Target attribute that specifies one or more sizes for a referenced icon.
  ///
  /// Only applicable for relation type "icon". The value pattern follows
  /// {Height}x{Width} (e.g., "16x16", "16x16 32x32").
  final String? sizes;

  /// The hreflang attribute specifies the language of a linked document.
  ///
  /// The value of this must be a valid language tag [BCP47][BCP47 link].
  ///
  /// [BCP47 link]: https://tools.ietf.org/search/bcp47
  final List<String>? hreflang;

  /// Additional fields collected during the parsing of a JSON object.
  final Map<String, dynamic>? additionalFields;
}
