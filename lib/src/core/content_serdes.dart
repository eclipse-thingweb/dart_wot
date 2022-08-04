// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http_parser/http_parser.dart';
import 'package:json_schema3/json_schema3.dart';

import '../definitions/data_schema.dart';
import 'codecs/cbor_codec.dart';
import 'codecs/codec_media_type.dart';
import 'codecs/content_codec.dart';
import 'codecs/json_codec.dart';
import 'codecs/link_format_codec.dart';
import 'content.dart';

/// Defines `application/json` as the default content type.
const defaultMediaType = 'application/json';

/// Custom [Exception] that is thrown when Serialization or Deserialization
/// fails.
// TODO(JKRhb): Add codecs for text-based media types
// TODO(JKRhb): Add codecs for XML based media types
// TODO(JKRhb): Add codecs for Base64 media types
// TODO(JKRhb): Add codec for OctetStream media type
class ContentSerdesException implements Exception {
  /// Constructor.
  ContentSerdesException(this.message);

  /// The error message of this [ContentSerdesException].
  String? message;

  @override
  String toString() {
    return 'ContentSerdesException: $message';
  }
}

/// Class providing serializing and deserializing capabilities.
///
// TODO(JKRhb): Decide if a class-based approach is the right way to go.
// TODO(JKRhb): Getters and setters might have to be revisited
class ContentSerdes {
  /// Creates a new [ContentSerdes] object which supports JSON and CBOR based
  /// media types by default.
  ContentSerdes();

  /// The supported codecs by this [ContentSerdes] object.
  ///
  /// Is initialized with support for JSON, CBOR, and the CoRE Link-Format.
  final _codecs = {
    CodecMediaType('application', 'json'): JsonCodec(),
    CodecMediaType('application', 'cbor'): CborCodec(),
    CodecMediaType('application', 'link-format'): LinkFormatCodec(),
  };

  final Set<String> _offeredMediaTypes = {
    'application/json',
    'application/cbor'
  };

  /// Parses a [String]-based [mediaType] and adds it to the set of
  /// [offeredMediaTypes].
  ///
  /// Throws an [HttpException] if the [mediaType] cannot be parsed and an
  /// [ArgumentError] if the [mediaType] should not be supported.
  void addOfferedMediaType(String mediaType) {
    final parsedMediaType = ContentType.parse(mediaType).toString();
    if (!isSupportedMediaType(parsedMediaType)) {
      throw ArgumentError.value(
        mediaType,
        'addOfferedMediaType',
        'Not a supported media type',
      );
    }

    _offeredMediaTypes.add(parsedMediaType);
  }

  /// Parses a [String]-based [mediaType] and removes it from the set of
  /// [offeredMediaTypes].
  ///
  /// Throws an [HttpException] if the [mediaType] cannot be parsed.
  void removeOfferedMediaType(String mediaType) {
    final parsedMediaType = ContentType.parse(mediaType).toString();
    _offeredMediaTypes.remove(parsedMediaType);
  }

  /// Register a new [codec] for a basic [codecMediaType].
  ///
  /// The [codecMediaType] should be a basic MIME-Type, consisting of a
  /// primary type (like `text` or `application`) and a basic subtype (like
  /// `plain` or`json`). Anything before a `+` (as in `application/td+json`)
  /// in a subtype as well as parameters (like `charset=utf-8`) are ignored when
  /// assigning the codec.
  ///
  /// Therefore, a codec assigned to `application/foo+bar;charset=utf-8` would
  /// be applied to all Content-Types that are derived from `application/bar`
  /// (like `application/baz+bar`, for example).
  ///
  /// If the [codecMediaType] cannot be parsed, an [ArgumentError] is thrown.
  void assignCodec(
    String codecMediaType,
    ContentCodec codec,
  ) {
    final parsedMediaType = CodecMediaType.parse(codecMediaType);

    if (parsedMediaType == null) {
      throw ArgumentError.value(
        codecMediaType,
        'codecMediaType',
        'Incorrect format',
      );
    }

    _codecs[parsedMediaType] = codec;
  }

  /// Checks if a given [mediaType] is supported.
  bool isSupportedMediaType(String mediaType) =>
      _getCodecFromMediaType(mediaType) != null;

  /// Returns a [List] of basic supported media types.
  List<String> get supportedMediaTypes => _codecs.keys
      .map((e) => '${e.prefix}/${e.suffix}')
      .toList(growable: false);

  /// Returns a [List] of media types which are offered when a Thing is exposed.
  List<String> get offeredMediaTypes =>
      _offeredMediaTypes.toList(growable: false);

  ContentCodec? _getCodecFromMediaType(String mediaType) {
    final parsedMediaType = CodecMediaType.parse(mediaType);

    return _codecs[parsedMediaType];
  }

  void _validateValue(Object? value, DataSchema? dataSchema) {
    final dataSchemaJson = dataSchema?.rawJson;
    if (dataSchemaJson == null) {
      return;
    }
    final schema =
        JsonSchema.create(dataSchemaJson, schemaVersion: SchemaVersion.draft7);
    if (!schema.validate(value).isValid) {
      throw ContentSerdesException('JSON Schema validation failed.');
    }
  }

  /// Converts an [Object] to a byte representation based on its [mediaType].
  ///
  /// A [dataSchema] can be passed for validating the input [value] before the
  /// conversion.
  Content valueToContent(
    Object? value,
    DataSchema? dataSchema,
    String? mediaType,
  ) {
    _validateValue(value, dataSchema);

    final resolvedMediaType = mediaType ?? defaultMediaType;

    final parsedMediaType = MediaType.parse(resolvedMediaType);
    final mimeType = parsedMediaType.mimeType;
    final parameters = parsedMediaType.parameters;

    ByteBuffer bytes;
    final codec = _getCodecFromMediaType(mimeType);
    if (codec != null) {
      bytes = codec.valueToBytes(value, dataSchema, parameters);
    } else {
      // Media Type is unsupported. Convert the String representation to bytes
      // instead.
      // TODO(JKRhb): Could be moved to a dedicated Value class method.
      bytes = utf8.encoder.convert(value.toString()).buffer;
    }

    final byteList = bytes.asUint8List().toList(growable: false);
    return Content(resolvedMediaType, Stream.value(byteList));
  }

  /// Converts a [Content] object to a typed [Object].
  ///
  /// A [dataSchema] can be passed for validating the result. If the media type
  /// specified in the [content] is not supported, its body is converted to an
  /// UTF-8 string.
  Future<Object?> contentToValue(
    Content content,
    DataSchema? dataSchema,
  ) async {
    final parsedMediaType = MediaType.parse(content.type);
    final mimeType = parsedMediaType.mimeType;
    final parameters = parsedMediaType.parameters;

    final bytes = await content.byteBuffer;

    // TODO: Should null be returned in this case?
    if (bytes.lengthInBytes == 0) {
      return null;
    }

    final codec = _getCodecFromMediaType(mimeType);
    if (codec != null) {
      final value = codec.bytesToValue(bytes, dataSchema, parameters);
      _validateValue(value, dataSchema);
      return value;
    } else {
      // TODO(JKRhb): Should unsupported data be returned as a String?
      return utf8.decode(bytes.asUint8List());
    }
  }
}
