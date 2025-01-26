// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "../implementation.dart";
import "../scripting_api.dart";

/// Base class for a Protocol Client.
abstract base class ProtocolClient {
  /// Starts this [ProtocolClient].
  Future<void> start();

  /// Stops this [ProtocolClient].
  Future<void> stop();

  /// Requests the client to perform a `readproperty` operation on a [form].
  Future<Content> readResource(AugmentedForm form);

  /// Requests the client to perform a `writeproperty` operation on a [form]
  /// using the given [content].
  Future<void> writeResource(AugmentedForm form, Content content);

  /// Requests the client to perform an `invokeaction` operation on a [form]
  /// using the given [content].
  Future<Content> invokeResource(AugmentedForm form, Content content);

  /// Requests the client to perform a `subscribeproperty` operation on a
  /// [form].
  Future<Subscription> subscribeResource(
    AugmentedForm form, {
    required void Function(Content content) next,
    required void Function() complete,
    void Function(Exception error)? error,
  });
}
