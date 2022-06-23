// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:typed_data';

import 'package:typed_data/typed_data.dart';

/// This class contains binary input or output data and indicates the media
/// type this data is encoded in.
class Content {
  /// Creates a new [Content] object from a media [type] and a [body].
  Content(this.type, this.body);

  /// The media type corresponding with this [Content] object.
  ///
  /// Examples would be `application/json` or `application/cbor`.
  final String type;

  /// The payload as a byte [Stream].
  final Stream<List<int>> body;

  /// Converts the [body] of the content to a [ByteBuffer] asynchronously.
  Future<ByteBuffer> get byteBuffer async {
    final buffer = Uint8Buffer();
    await for (final bytes in body) {
      buffer.addAll(bytes);
    }
    return buffer.buffer;
  }
}
