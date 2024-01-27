// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:typed_data";

import "../definitions/data_schema.dart";
import "../definitions/form.dart";
import "../exceptions.dart";
import "../scripting_api.dart" as scripting_api;
import "content.dart";
import "content_serdes.dart";

/// Implementation of the [scripting_api.InteractionOutput] interface.
class InteractionOutput implements scripting_api.InteractionOutput {
  /// Creates a new [InteractionOutput] based on a [Content] object.
  ///
  /// A [_contentSerdes] object has to be passed for decoding the raw
  /// payload contained in the [_content] object.
  ///
  /// In contrast to the interface definition in the
  /// [Scripting API specification], [_form] is defined as non-nullable here,
  /// since other parts of the code never pass a `null` value as an argument for
  /// this parameter.
  ///
  /// [Scripting API specification]: https://w3c.github.io/wot-scripting-api/#the-interactionoutput-interface
  InteractionOutput(
    this._content,
    this._contentSerdes,
    this._form,
    this._schema,
  ) : _data = _content.body;

  final Content _content;
  final Form _form;
  final DataSchema? _schema;
  final Stream<List<int>> _data;

  final ContentSerdes _contentSerdes;

  bool _dataUsed = false;

  scripting_api.DataSchemaValue? _value;

  @override
  Future<ByteBuffer> arrayBuffer() async {
    if (dataUsed) {
      throw const NotReadableException("Data has already been read");
    }

    _dataUsed = true;
    return _content.byteBuffer;
  }

  @override
  bool get dataUsed => _dataUsed;

  @override
  Future<Object?> value() async {
    final existingValue = _value;
    if (existingValue != null) {
      return existingValue.value;
    }

    if (schema == null) {
      throw const NotReadableException(
        "Can't convert data to a value because no DataSchema is present.",
      );
    }

    final value = await _contentSerdes.contentToValue(
      _content,
      schema,
    );
    _dataUsed = true;

    _value = value;
    return value?.value;
  }

  @override
  Stream<List<int>>? get data => _data;

  @override
  DataSchema? get schema => _schema;

  @override
  Form get form => _form;
}
