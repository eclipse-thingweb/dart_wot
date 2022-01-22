// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

/// Represents an element of the `links` array in a Thing Description.
///
/// A link can be viewed as a statement of the form "link context has a relation
/// type resource at link target", where the optional target attributes may
/// further describe the resource.
class Link {
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

  final List<String> _parsedJsonFields = [];

  /// Additional fields collected during the parsing of a JSON object.
  final Map<String, dynamic> additionalFields = <String, dynamic>{};

  /// Constructor.
  Link(
    String href, {
    this.type,
    this.rel,
    String? anchor,
    this.sizes,
    Map<String, dynamic>? additionalFields,
  })  : href = Uri.parse(href),
        anchor = anchor != null ? Uri.parse(anchor) : null {
    if (additionalFields != null) {
      this.additionalFields.addAll(additionalFields);
    }
  }

  /// Creates a new [Link] from a [json] object.
  Link.fromJson(Map<String, dynamic> json) {
    // TODO(JKRhb): Check if this can be refactored
    if (json["href"] is String) {
      _parsedJsonFields.add("href");
      final hrefString = json["href"] as String;
      href = Uri.parse(hrefString);
    } else {
      // [href] *must* be initialized.
      throw ArgumentError("'href' field must exist as a string.", "formJson");
    }

    if (json["type"] is String) {
      _parsedJsonFields.add("type");
      type = json["type"] as String;
    }

    if (json["rel"] is String) {
      _parsedJsonFields.add("rel");
      rel = json["rel"] as String;
    }

    if (json["anchor"] is String) {
      _parsedJsonFields.add("anchor");
      anchor = Uri.parse(json["anchor"] as String);
    }

    if (json["sizes"] is String) {
      _parsedJsonFields.add("sizes");
      sizes = json["sizes"] as String;
    }

    _addAdditionalFields(json);
  }

  void _addAdditionalFields(Map<String, dynamic> formJson) {
    for (final entry in formJson.entries) {
      if (!_parsedJsonFields.contains(entry.key)) {
        additionalFields[entry.key] = entry.value;
      }
    }
  }
}
