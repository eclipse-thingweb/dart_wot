// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:typed_data";

import "../definitions.dart";

/// Exposes the data obtained by Thing interactions.
///
/// See [WoT Scripting API Specification, Section 7.2][spec link].
///
/// [spec link]: https://w3c.github.io/wot-scripting-api/#the-interactionoutput-interface
abstract interface class InteractionOutput {
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

  /// Asynchronously creates a [ByteBuffer] representation of the value of
  /// of the [InteractionOutput].
  ///
  /// Follows the algorithm defined for the `arrayBuffer()` function in the
  /// Scripting API specification.
  ///
  /// [algorithm]: https://w3c.github.io/wot-scripting-api/#the-arraybuffer-function
  Future<ByteBuffer> arrayBuffer();

  /// The parsed value of the [InteractionOutput].
  ///
  ///
  /// Follows the algorithm defined for the `arrayBuffer()` function in the
  /// Scripting API specification.
  ///
  /// [algorithm]: https://w3c.github.io/wot-scripting-api/#the-value-function
  Future<Object?> value();
}
