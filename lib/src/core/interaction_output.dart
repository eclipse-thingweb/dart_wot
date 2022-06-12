// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:typed_data';

import '../../scripting_api.dart' as scripting_api;
import '../definitions/data_schema.dart';
import '../definitions/form.dart';
import 'content.dart';
import 'content_serdes.dart';

/// Implementation of the [scripting_api.InteractionOutput] interface.
class InteractionOutput implements scripting_api.InteractionOutput {
  /// Creates a new [InteractionOutput] based on a [Content] object.
  ///
  /// A [ContentSerdes] object has to be passed for decoding the raw
  /// payload contained in the [Content] object.
  InteractionOutput(this._content, this._contentSerdes,
      [this._form, this._schema])
      : _data = _content.body;

  final Content _content;
  final Form? _form;
  final DataSchema? _schema;
  final Stream<List<int>> _data;

  final ContentSerdes _contentSerdes;

  bool _dataUsed = false;

  @override
  Future<ByteBuffer> arrayBuffer() async {
    _dataUsed = true;
    return _content.byteBuffer;
  }

  @override
  bool get dataUsed => _dataUsed;

  @override
  Future<Object?> value() async {
    _dataUsed = true;
    return _contentSerdes.contentToValue(_content, schema);
  }

  @override
  Stream<List<int>>? get data => _data;

  @override
  DataSchema? get schema => _schema;

  @override
  Form? get form => _form;
}
