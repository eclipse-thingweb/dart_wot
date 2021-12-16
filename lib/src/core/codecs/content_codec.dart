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

import '../../definitions/data_schema.dart';

/// Interface for providing a codec for a specific media type.
abstract class ContentCodec {
  /// Converts an [Object] to its byte representation in the given media type.
  ByteBuffer valueToBytes(
      Object? value, DataSchema? dataSchema, Map<String, String>? parameters);

  /// Converts a payload of the given media type to an [Object].
  Object? bytesToValue(ByteBuffer bytes, DataSchema? dataSchema,
      Map<String, String>? parameters);
}
