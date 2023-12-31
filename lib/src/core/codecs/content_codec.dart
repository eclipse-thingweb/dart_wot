// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../../definitions/data_schema.dart';
import '../../scripting_api/data_schema_value.dart';

/// Interface for providing a codec for a specific media type.
abstract class ContentCodec {
  /// Converts an [Object] to its byte representation in the given media type.
  List<int> valueToBytes(
    DataSchemaValue<Object?> value,
    DataSchema? dataSchema,
    Map<String, String>? parameters,
  );

  /// Converts a payload of the given media type to an [Object].
  DataSchemaValue<Object?>? bytesToValue(
    List<int> bytes,
    DataSchema? dataSchema,
    Map<String, String>? parameters,
  );
}
