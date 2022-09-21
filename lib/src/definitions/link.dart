// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'extensions/json_parser.dart';

/// Represents an element of the `links` array in a Thing Description.
///
/// A link can be viewed as a statement of the form "link context has a relation
/// type resource at link target", where the optional target attributes may
/// further describe the resource.
class Link {
  /// Constructor.
  Link(
    String href, {
    this.type,
    this.rel,
    String? anchor,
    this.sizes,
    this.hreflang,
    Map<String, dynamic>? additionalFields,
  })  : href = Uri.parse(href),
        anchor = anchor != null ? Uri.parse(anchor) : null {
    if (additionalFields != null) {
      this.additionalFields.addAll(additionalFields);
    }
  }

  /// Creates a new [Link] from a [json] object.
  Link.fromJson(Map<String, dynamic> json) {
    final Set<String> parsedFields = {};

    href = Uri.parse(json.parseRequiredField<String>('href', parsedFields));
    type = json.parseField<String>('@type', parsedFields);
    rel = json.parseField<String>('rel', parsedFields);
    anchor =
        Uri.tryParse(json.parseField<String>('anchor', parsedFields) ?? '');
    sizes = json.parseField<String>('sizes', parsedFields);
    hreflang = json.parseArrayField<String>('hreflang', parsedFields);

    additionalFields.addAll(
      Map.fromEntries(
        json.entries.where((element) => !parsedFields.contains(element.key)),
      ),
    );
  }

  /// Target IRI of a link or submission target of a form.
  late final Uri href;

  /// Target attribute providing a hint indicating what the media type (see RFC
  /// 2046) of the result of dereferencing the link should be.
  String? type;

  /// A link relation type identifies the semantics of a link.
  String? rel;

  /// Overrides the link context (by default the Thing itself identified by its
  /// id) with the given URI or IRI.
  Uri? anchor;

  /// Target attribute that specifies one or more sizes for a referenced icon.
  ///
  /// Only applicable for relation type "icon". The value pattern follows
  /// {Height}x{Width} (e.g., "16x16", "16x16 32x32").
  String? sizes;

  /// The hreflang attribute specifies the language of a linked document.
  ///
  /// The value of this must be a valid language tag [BCP47][BCP47 link].
  ///
  /// [BCP47 link]: https://tools.ietf.org/search/bcp47
  List<String>? hreflang;

  /// Additional fields collected during the parsing of a JSON object.
  final Map<String, dynamic> additionalFields = <String, dynamic>{};
}
