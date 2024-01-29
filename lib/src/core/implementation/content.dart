// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:typed_data";

import "package:meta/meta.dart";
import "package:typed_data/typed_data.dart";

import "../definitions/data_schema.dart";
import "../scripting_api/interaction_input.dart";
import "content_serdes.dart";

/// This class contains binary input or output data and indicates the media
/// type this data is encoded in.
class Content {
  /// Creates a new [Content] object from a media [type] and a [body].
  Content(
    this.type,
    this.body, {
    this.additionalData,
  });

  /// Creates a new [Content] object from an [interactionInput].
  ///
  /// If the [interactionInput] is not a [StreamInput], it will be converted to
  /// a [Stream] by the referenced [contentSerdes] if it supports the specified
  /// [contentType].
  /// In this case, the optional [dataSchema] will be used for validation before
  /// the conversion.
  factory Content.fromInteractionInput(
    InteractionInput? interactionInput,
    String contentType,
    ContentSerdes contentSerdes,
    DataSchema? dataSchema,
  ) {
    if (interactionInput == null) {
      return Content(contentType, const Stream.empty());
    }

    switch (interactionInput) {
      case DataSchemaValueInput():
        return contentSerdes.valueToContent(
          interactionInput.dataSchemaValue,
          dataSchema,
          contentType,
        );
      case StreamInput():
        return Content(contentType, interactionInput.byteStream);
    }
  }

  /// The media type corresponding with this [Content] object.
  ///
  /// Examples would be `application/json` or `application/cbor`.
  final String type;

  /// The payload as a byte [Stream].
  final Stream<List<int>> body;

  /// Field used to pass additional, protocol-specific information upstream.
  ///
  /// One example for this could be HTTP headers.
  @experimental
  final Map<String, Object?>? additionalData;

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
    this.sourceUri, {
    super.additionalData,
  });

  /// Creates a new [DiscoveryContent] object from regular [Content] and a
  /// [sourceUri].
  DiscoveryContent.fromContent(Content content, this.sourceUri)
      : super(content.type, content.body);

  /// The source of this [DiscoveryContent].
  ///
  /// Relevant when following up to multicast discovery with a unicast request.
  final Uri sourceUri;
}
