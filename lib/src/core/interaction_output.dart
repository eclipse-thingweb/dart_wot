// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import 'dart:typed_data';

import '../../scripting_api.dart' as scripting_api;
import '../definitions/data_schema.dart';
import '../definitions/form.dart';
import 'content.dart';
import 'content_serdes.dart';

/// Implementation of the [scripting_api.InteractionOutput] interface.
class InteractionOutput implements scripting_api.InteractionOutput {
  final Content _content;
  final Form? _form;
  final DataSchema? _schema;
  final Stream<List<int>> _data;

  final ContentSerdes _contentSerdes;

  bool _dataUsed = false;

  /// Creates a new [InteractionOutput] based on a [Content] object.
  ///
  /// A [ContentSerdes] object has to be passed for decoding the raw
  /// payload contained in the [Content] object.
  InteractionOutput(this._content, this._contentSerdes,
      [this._form, this._schema])
      : _data = _content.body;

  @override
  Future<ByteBuffer> arrayBuffer() async {
    _dataUsed = true;
    return await _content.byteBuffer;
  }

  @override
  bool get dataUsed => _dataUsed;

  @override
  Future<Object?> value() async {
    _dataUsed = true;
    return await _contentSerdes.contentToValue(_content, schema);
  }

  @override
  Stream<List<int>>? get data => _data;

  @override
  DataSchema? get schema => _schema;

  @override
  Form? get form => _form;
}
