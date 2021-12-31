// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import '../../../scripting_api.dart';
import '../credentials.dart';

/// Base class for a Protocol Server.
abstract class ProtocolServer {
  /// The [port] number used by this Server.
  int get port;

  /// The protocol [scheme] associated with this server.
  String get scheme;

  // TODO(JKRhb): Check if a Servient should be passed as a parameter instead
  /// Starts the server. Accepts a [Map] of [credentials].
  Future<void> start(Map<String, Credentials> credentials);

  /// Stops the server.
  Future<void> stop();

  /// Exposes a [thing].
  Future<void> expose(ExposedThing thing);
}
