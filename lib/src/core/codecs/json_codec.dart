// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:convert';

import '../../definitions/data_schema.dart';

import 'content_codec.dart';

/// A [ContentCodec] that encodes and decodes JSON data.
class JsonCodec extends ContentCodec {
  @override
  List<int> valueToBytes(
    Object? value,
    DataSchema? dataSchema,
    Map<String, String>? parameters,
  ) {
    return utf8.encode(jsonEncode(value));
  }

  @override
  Object? bytesToValue(
    List<int> bytes,
    DataSchema? dataSchema,
    Map<String, String>? parameters,
  ) {
    // TODO(JKRhb): Use dataSchema for validation

    return jsonDecode(utf8.decoder.convert(bytes));
  }
}
