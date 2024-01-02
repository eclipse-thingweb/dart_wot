// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "../../../scripting_api.dart";
import "../credentials/callbacks.dart";

/// Base class for a Protocol Server.
abstract interface class ProtocolServer {
  /// The [port] number used by this Server.
  int get port;

  /// The protocol [scheme] associated with this server.
  String get scheme;

  // TODO(JKRhb): Check if a Servient should be passed as a parameter instead
  /// Starts the server. Accepts a callback for retrieving a [Map] of
  /// credentials for [ExposedThing]s at runtime.
  Future<void> start([ServerSecurityCallback? serverSecurityCallback]);

  /// Stops the server.
  Future<void> stop();

  /// Exposes a [thing].
  Future<void> expose(ExposedThing thing);
}
