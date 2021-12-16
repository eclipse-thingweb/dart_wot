// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import 'dart:typed_data';

import 'package:typed_data/typed_data.dart';

/// Is thrown when the Deserialization of a [Content] object fails.
class ContentDeserializationException implements Exception {
  /// The error message associated with this [ContentDeserializationException].
  final String message;

  /// The original error.
  final Object error;

  /// Creates a new [ContentDeserializationException] with an error [message].
  ContentDeserializationException(this.message, this.error);
}

void _onError(Object error) {
  throw ContentDeserializationException(
      "Error occurred when reading data from stream: $error", error);
}

/// This class contains binary input or output data and indicates the media
/// type this data is encoded in.
class Content {
  /// The media type corresponding with this [Content] object.
  ///
  /// Examples would be `application/json` or `application/cbor`.
  String type;

  /// The payload as a byte [Stream].
  Stream<List<int>> body;

  /// Creates a new [Content] object from a media [type] and a [body].
  Content(this.type, this.body);

  /// Converts the [body] of the content to a [ByteBuffer] asynchronously.
  Future<ByteBuffer> get byteBuffer async {
    final buffer = Uint8Buffer();
    final subscription = body.listen(
      buffer.addAll,
      onError: _onError,
      cancelOnError: true,
    );
    await subscription.asFuture<void>();
    await subscription.cancel();
    return buffer.buffer;
  }
}
