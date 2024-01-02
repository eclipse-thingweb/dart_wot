// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:cbor/cbor.dart" as cbor;

import "../../definitions/data_schema.dart";
import "../../scripting_api/data_schema_value.dart";
import "content_codec.dart";

/// A [ContentCodec] that encodes and decodes CBOR data.
class CborCodec extends ContentCodec {
  @override
  List<int> valueToBytes(
    DataSchemaValue? dataSchemaValue,
    DataSchema? dataSchema,
    Map<String, String>? parameters,
  ) {
    if (dataSchemaValue == null) {
      return [];
    }

    final cborValue = cbor.CborValue(dataSchemaValue.value);

    return cbor.cborEncode(cborValue);
  }

  @override
  DataSchemaValue? bytesToValue(
    List<int> bytes,
    DataSchema? dataSchema,
    Map<String, String>? parameters,
  ) {
    final cborObject = cbor.cborDecode(bytes).toObject();

    return DataSchemaValue.tryParse(cborObject);
  }
}
