// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "../definitions.dart";
import "../implementation.dart";

/// Interface that allows ProtocolServers to interact with ExposedThings.
// TODO: This needs a better name
abstract interface class ExposableThing {
  /// The [ThingDescription] that represents this [ExposableThing].
  ThingDescription get thingDescription;

  /// Handles a `readproperty` operation triggered by a TD consumer.
  Future<Content> handleReadProperty(
    String propertyName, {
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  });

  /// Handles a `writeproperty` operation triggered by a TD consumer.
  Future<void> handleWriteProperty(
    String propertyName,
    Content input, {
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  });

  /// Handles a `invokeaction` operation triggered by a TD consumer.
  Future<Content?> handleInvokeAction(
    String propertyName,
    Content input, {
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  });
}
