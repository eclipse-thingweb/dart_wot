// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

/// Interface for converting a class object [toJson].
abstract interface class Serializable {
  /// Converts this class object into a JSON value.
  dynamic toJson();
}
