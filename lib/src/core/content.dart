// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
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
    final buffer = Uint8Buffer()..addAll(await toByteList());

    return buffer.buffer;
  }

  /// Converts the [body] of this [Content] to a [List] of bytes asynchronously.
  Future<List<int>> toByteList() async =>
      body.expand<int>((element) => element).toList();
}

/// [Content] specific for discovery.
///
/// Mostly used for being able to convert results from multicast discovery to
/// unicast discovery operations.
class DiscoveryContent extends Content {
  /// Creates a new [Content] object from a media [type], a [body], and an
  /// optional [sourceUri].
  DiscoveryContent(
    super.type,
    super.body,
    this.sourceUri,
  );

  /// Creates a new [DiscoveryContent] object from regular [Content] and a
  /// [sourceUri].
  DiscoveryContent.fromContent(Content content, this.sourceUri)
      : super(content.type, content.body);

  /// The source of this [DiscoveryContent].
  ///
  /// Relevant when following up to multicast discovery with a unicast request.
  final Uri sourceUri;
}
