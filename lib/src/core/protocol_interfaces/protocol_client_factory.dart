// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:meta/meta.dart";

import "../definitions.dart";
import "protocol_client.dart";

/// Base class for a factory that produces [ProtocolClient]s.
abstract interface class ProtocolClientFactory {
  /// The protocol [schemes] support of the clients this factory produces.
  Set<String> get schemes;

  /// Initializes this [ProtocolClientFactory].
  ///
  /// Returns `true` on success.
  bool init();

  /// Destroys this [ProtocolClientFactory].
  ///
  /// Returns `true` on success.
  bool destroy();

  /// Creates a new [ProtocolClient] with that supports one or more of the given
  /// [schemes].
  ProtocolClient createClient();

  /// Indicates whether this [ProtocolClientFactory] supports a given
  /// [operationType] and subprotocol.
  @experimental
  bool supportsOperation(OperationType operationType, String? subprotocol);
}
