// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:meta/meta.dart";

import "../scripting_api.dart";

/// Base class for implementations of the [Subscription] interface.
abstract base class ProtocolSubscription implements Subscription {
  /// Instantiates a new [ProtocolSubscription].
  ///
  /// The [_complete] callback will be called when the [ProtocolSubscription]
  /// has been [stop]ped (either internally or externally).
  ProtocolSubscription(this._complete);

  final void Function() _complete;

  @override
  @mustCallSuper
  Future<void> stop({
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  }) async {
    _complete();
  }
}
