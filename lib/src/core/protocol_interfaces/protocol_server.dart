// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "../implementation/exposed_thing.dart";
import "../implementation/servient.dart";
import "exposable_thing.dart";

/// Base class for a Protocol Server.
abstract interface class ProtocolServer {
  /// The [port] number used by this Server.
  int get port;

  /// The protocol [scheme] associated with this server.
  String get scheme;

  /// Starts the server. Accepts a callback for retrieving a [Map] of
  /// credentials for [ExposedThing]s at runtime.
  Future<void> start(Servient servient);

  /// Stops the server.
  Future<void> stop();

  /// Exposes a [thing].
  Future<void> expose(ExposableThing thing);

  /// Removes a [thing] from this server.
  Future<void> destroyThing(ExposableThing thing);
}
