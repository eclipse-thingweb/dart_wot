// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import 'dart:convert';
import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:typed_data/typed_data.dart';

import '../../definitions/data_schema.dart';
import 'content_codec.dart';

/// A [ContentCodec] that encodes and decodes CBOR data.
class CborCodec extends ContentCodec {
  final Cbor _cborConverter = Cbor();

  @override
  ByteBuffer valueToBytes(
      Object? value, DataSchema? dataSchema, Map<String, String>? parameters) {
    // TODO(JKRhb): Make sure that exceptions are handled.
    // TODO(JKRhb): Should more data types be supported? (Probably not I guess.)

    if (value == null) {
      return Uint8List(0).buffer;
    } else {
      var success = true;

      if (value is Map) {
        success = _cborConverter.encoder.writeMap(value);
      } else if (value is int) {
        _cborConverter.encoder.writeInt(value);
      } else if (value is double) {
        _cborConverter.encoder.writeFloat(value);
      } else if (value is String) {
        _cborConverter.encoder.writeString(value);
      } else if (value is bool) {
        _cborConverter.encoder.writeBool(value);
      } else if (value is List) {
        success = _cborConverter.encoder.writeArray(value);
      } else {
        throw UnsupportedError(
            "CBOR encoder encountered invalid unsupported type "
            "${value.runtimeType}.");
      }

      if (!success) {
        throw ArgumentError(
            "CBOR encoding of data type ${value.runtimeType} failed!");
      }

      final bytes = _cborConverter.output.getData();
      _cborConverter.clearDecodeStack();
      return bytes.buffer;
    }
  }

  @override
  Object? bytesToValue(ByteBuffer bytes, DataSchema? dataSchema,
      Map<String, String>? parameters) {
    // TODO(JKRhb): Use dataSchema for validation
    // TODO(JKRhb): Check if there is a more elegant way for dealing with CBOR
    //              decoding

    final buffer = Uint8Buffer()..addAll(bytes.asUint8List());

    _cborConverter.decodeFromBuffer(buffer);
    final jsonString = _cborConverter.decodedToJSON();
    _cborConverter.clearDecodeStack();

    if (jsonString != null) {
      return jsonDecode(jsonString);
    } else {
      return null;
    }
  }
}
