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

import '../definitions/data_schema.dart';
import '../definitions/form.dart';

/// Exposes the data obtained by Thing interactions.
///
/// See [WoT Scripting API Specification, Section 7.2][spec link].
///
/// [spec link]: https://w3c.github.io/wot-scripting-api/#the-interactionoutput-interface
abstract class InteractionOutput {
  /// The raw payload of the [InteractionOutput] as a Byte [Stream].
  Stream<List<int>>? get data;

  /// Indicates if the [data] has already been retrieved from this
  /// [InteractionOutput].
  bool get dataUsed;

  /// The [Form] corresponding to this [InteractionOutput].
  Form? get form;

  /// An optional [DataSchema] which can be used for validating the
  /// [InteractionOutput].
  DataSchema? get schema;

  /// Asyncronously creates a [ByteBuffer] representation of the value of
  /// of the [InteractionOutput].
  Future<ByteBuffer> arrayBuffer();

  // TODO(JKRhb): Replace with some kind of DataSchemaValue
  /// The parsed value of the [InteractionOutput].
  Future<Object?> value();
}
