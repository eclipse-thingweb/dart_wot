// Copyright 2023 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:convert";

import "../../definitions.dart";
import "../../scripting_api.dart";
import "content_codec.dart";

const _utf8Coding = "utf-8";

/// A [ContentCodec] that encodes and decodes plain text data.
class TextCodec extends ContentCodec {
  @override
  List<int> valueToBytes(
    DataSchemaValue? dataSchemaValue,
    DataSchema? dataSchema,
    Map<String, String>? parameters,
  ) {
    if (dataSchemaValue == null) {
      return [];
    }

    final rawValue = dataSchemaValue.value.toString();

    final coding = parameters.coding;

    switch (coding) {
      case _utf8Coding:
        return utf8.encode(rawValue);
      default:
        throw FormatException("Encountered unsupported text coding $coding");
    }
  }

  @override
  DataSchemaValue? bytesToValue(
    List<int> bytes,
    DataSchema? dataSchema,
    Map<String, String>? parameters,
  ) {
    if (bytes.isEmpty) {
      return null;
    }

    final coding = parameters.coding;

    switch (coding) {
      case _utf8Coding:
        return DataSchemaValue.fromString(utf8.decoder.convert(bytes));
      default:
        throw FormatException("Encountered unsupported text coding $coding");
    }
  }
}

extension _ParametersExtension on Map<String, String>? {
  String get coding => this?["charset"]?.toLowerCase() ?? _utf8Coding;
}
