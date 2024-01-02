// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:convert";

import "../../definitions/data_schema.dart";

import "../../scripting_api/data_schema_value.dart";
import "content_codec.dart";

/// A [ContentCodec] that encodes and decodes JSON data.
class JsonCodec extends ContentCodec {
  @override
  List<int> valueToBytes(
    DataSchemaValue? dataSchemaValue,
    DataSchema? dataSchema,
    Map<String, String>? parameters,
  ) {
    if (dataSchemaValue == null) {
      return [];
    }

    return utf8.encode(jsonEncode(dataSchemaValue.value));
  }

  @override
  DataSchemaValue? bytesToValue(
    List<int> bytes,
    DataSchema? dataSchema,
    Map<String, String>? parameters,
  ) {
    // TODO(JKRhb): Use dataSchema for validation

    if (bytes.isEmpty) {
      return null;
    }

    final decodedJson = jsonDecode(utf8.decoder.convert(bytes));

    return DataSchemaValue.tryParse(decodedJson);
  }
}
