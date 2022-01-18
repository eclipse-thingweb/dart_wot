// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:convert';
import 'dart:typed_data';

import '../../definitions/data_schema.dart';

import 'content_codec.dart';

/// A [ContentCodec] that encodes and decodes JSON data.
class JsonCodec extends ContentCodec {
  @override
  ByteBuffer valueToBytes(
      Object? value, DataSchema? dataSchema, Map<String, String>? parameters) {
    if (value == null) {
      return Uint8List(0).buffer;
    } else {
      // TODO(JKRhb): This probably has to be revisited
      final utf8List = utf8.encode(jsonEncode(value));
      return Uint8List.fromList(utf8List).buffer;
    }
  }

  @override
  Object? bytesToValue(ByteBuffer bytes, DataSchema? dataSchema,
      Map<String, String>? parameters) {
    // TODO(JKRhb): Use dataSchema for validation

    return jsonDecode(utf8.decoder.convert(bytes.asUint8List()));
  }
}
