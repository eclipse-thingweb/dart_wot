// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "../../core.dart";

/// Extension for determining the HTTP method that corresponds with an
/// [OperationType].
extension HttpMethodExtension on OperationType {
  /// Returns the default HTTP method as defined in the [HTTP binding template]
  /// specification.
  ///
  /// If the [OperationType] value has no default method defined, an
  /// [ArgumentError] will be thrown.
  ///
  /// [HTTP binding template]: https://w3c.github.io/wot-binding-templates/bindings/protocols/http/#http-default-vocabulary-terms
  String get defaultHttpMethod {
    switch (this) {
      case OperationType.readproperty:
        return "GET";
      case OperationType.writeproperty:
        return "PUT";
      case OperationType.invokeaction:
        return "POST";
      case OperationType.readallproperties:
        return "GET";
      case OperationType.writeallproperties:
        return "PUT";
      case OperationType.readmultipleproperties:
        return "GET";
      case OperationType.writemultipleproperties:
        return "PUT";
      default:
        throw ArgumentError(
          "OperationType $this has no default HTTP method defined.",
        );
    }
  }
}
