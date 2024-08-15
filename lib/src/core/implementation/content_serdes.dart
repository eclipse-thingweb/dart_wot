// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:io";

import "package:http_parser/http_parser.dart";
import "package:json_schema/json_schema.dart";

import "../definitions/data_schema.dart";
import "../scripting_api/data_schema_value.dart";
import "codecs/cbor_codec.dart";
import "codecs/codec_media_type.dart";
import "codecs/content_codec.dart";
import "codecs/json_codec.dart";
import "codecs/text_codec.dart";
import "content.dart";

/// Defines `application/json` as the default content type.
const defaultMediaType = "application/json";

// TODO(JKRhb): Add codecs for XML based media types
// TODO(JKRhb): Add codecs for Base64 media types
// TODO(JKRhb): Add codec for OctetStream media type

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
    CodecMediaType("application", "json"): JsonCodec(),
    CodecMediaType("application", "cbor"): CborCodec(),
    CodecMediaType("application", "link-format"): TextCodec(),
    CodecMediaType("text", "plain"): TextCodec(),
  };

  final Set<String> _offeredMediaTypes = {
    "application/json",
    "application/cbor",
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
        "addOfferedMediaType",
        "Not a supported media type",
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
        "codecMediaType",
        "Incorrect format",
      );
    }

    _codecs[parsedMediaType] = codec;
  }

  /// Checks if a given [mediaType] is supported.
  bool isSupportedMediaType(String mediaType) =>
      _getCodecFromMediaType(mediaType) != null;

  /// Returns a [List] of basic supported media types.
  List<String> get supportedMediaTypes => _codecs.keys
      .map((e) => "${e.prefix}/${e.suffix}")
      .toList(growable: false);

  /// Returns a [List] of media types which are offered when a Thing is exposed.
  List<String> get offeredMediaTypes =>
      _offeredMediaTypes.toList(growable: false);

  ContentCodec? _getCodecFromMediaType(String mediaType) {
    final parsedMediaType = CodecMediaType.parse(mediaType);

    return _codecs[parsedMediaType];
  }

  void _validateValue(
    DataSchemaValue<Object?>? dataSchemaValue,
    DataSchema? dataSchema,
  ) {
    if (dataSchema == null) {
      return;
    }

    // TODO(JKRhb): The process of validating values according to a dataschema
    //              needs to be reworked.
    const filteredKeys = ["uriVariables"];

    final filteredDataSchemaJson = dataSchema
        .toJson()
        .entries
        .where((element) => !filteredKeys.contains(element.key));

    if (filteredDataSchemaJson.isEmpty) {
      return;
    }

    if (dataSchemaValue == null) {
      throw const FormatException("Expected a defined dataSchemaValue");
    }

    final schema = JsonSchema.create(
      Map.fromEntries(filteredDataSchemaJson),
      schemaVersion: SchemaVersion.draft7,
    );
    if (!schema.validate(dataSchemaValue.value).isValid) {
      throw const FormatException("JSON Schema validation failed.");
    }
  }

  /// Converts a [value] to a byte representation based on its [mediaType].
  ///
  /// The passed [value] is validated before the conversion in accordance to the
  /// [dataSchema] that is being passed to the method.
  /// The [value] might be `null`, indicating that an equivalent of JavaScript's
  /// `undefined` is being passed to the method.
  /// In this case, validation fails if a non-empty [dataSchema] is present,
  /// as some kind of [DataSchemaValue] is expected.
  ///
  /// If the indicated [mediaType] is not supported, the method will try to try
  /// to treat it as a UTF-8 string.
  Content valueToContent(
    DataSchemaValue<Object?>? value,
    DataSchema? dataSchema, [
    String? mediaType,
  ]) {
    final resolvedMediaType = mediaType ?? defaultMediaType;

    _validateValue(value, dataSchema);

    if (value == null) {
      return Content(resolvedMediaType, const Stream.empty());
    }

    final parsedMediaType = MediaType.parse(resolvedMediaType);
    final mimeType = parsedMediaType.mimeType;
    final parameters = parsedMediaType.parameters;

    // TODO(JKRhb): Reevaluate usage of TextCodec here
    final codec = _getCodecFromMediaType(mimeType) ?? TextCodec();

    final bytes = codec.valueToBytes(value, dataSchema, parameters);
    return Content(resolvedMediaType, Stream.value(bytes));
  }

  /// Converts a [Content] object to a typed [Object].
  ///
  /// A [dataSchema] can be passed for validating the result. If the media type
  /// specified in the [content] is not supported, the method will try to
  /// convert its body to an UTF-8 string.
  Future<DataSchemaValue<Object?>?> contentToValue(
    Content content,
    DataSchema? dataSchema,
  ) async {
    final parsedMediaType = MediaType.parse(content.type);
    final mimeType = parsedMediaType.mimeType;
    final parameters = parsedMediaType.parameters;

    final bytes = await content.toByteList();
    // TODO(JKRhb): Reevaluate usage of TextCodec here
    final codec = _getCodecFromMediaType(mimeType) ?? TextCodec();

    final value = codec.bytesToValue(bytes, dataSchema, parameters);

    if (value != null) {
      _validateValue(value, dataSchema);
    }
    return value;
  }
}
