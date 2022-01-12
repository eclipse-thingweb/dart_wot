// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import 'protocol_client.dart';

/// Base class for a factory that produces [ProtocolClient]s.
abstract class ProtocolClientFactory {
  /// The protocol [schemes] support of the clients this factory produces.
  Set<String> get schemes;

  /// Initalizes this [ProtocolClientFactory].
  ///
  /// Returns `true` on success.
  bool init();

  /// Destroys this [ProtocolClientFactory].
  ///
  /// Returns `true` on success.
  bool destroy();

  /// Creates a new [ProtocolClient] with the given [scheme].
  ProtocolClient createClient();
}
