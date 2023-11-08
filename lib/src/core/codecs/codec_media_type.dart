// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

/// Basic class for associating a codec to a minimal Content-Type.
class CodecMediaType {
  /// Constructor.
  CodecMediaType(this.prefix, this.suffix);

  /// The prefix of this [CodecMediaType], e.g., `application` or `text`.
  final String prefix;

  /// The suffix of this [CodecMediaType], e.g., `json` or `plain`.
  final String suffix;

  @override
  int get hashCode => Object.hash(prefix, suffix);

  @override
  bool operator ==(Object other) =>
      other is CodecMediaType &&
      other.runtimeType == runtimeType &&
      other.prefix == prefix &&
      other.suffix == suffix;

  /// Tries to parse a string-based [mediaType] and returns a [CodecMediaType]
  /// on success or `null` otherwise.
  ///
  /// When passing a [mediaType] like `application/td+json`, the part before the
  /// `+` in the subtype will be ignored (the result will become
  /// `application/json`). The same holds true for parameters like
  /// `charset=utf-8`.
  static CodecMediaType? parse(String mediaType) {
    final splitMediaType = mediaType.split('/');

    if (splitMediaType.length < 2) {
      return null;
    }

    final prefix = splitMediaType.first;

    if (prefix.isEmpty) {
      return null;
    }

    final suffix = splitMediaType[1].split(';').first.split('+').last;

    if (suffix.isEmpty) {
      return null;
    }

    return CodecMediaType(prefix, suffix);
  }
}
