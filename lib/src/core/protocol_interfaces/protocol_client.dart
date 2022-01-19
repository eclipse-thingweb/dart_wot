// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../../definitions/form.dart';
import '../../definitions/security_scheme.dart';
import '../../scripting_api/subscription.dart';
import '../content.dart';
import '../credentials.dart';

/// Base class for a Protocol Client.
abstract class ProtocolClient {
  /// Starts this [ProtocolClient].
  Future<void> start();

  /// Stops this [ProtocolClient].
  Future<void> stop();

  /// Requests the client to perform a `readproperty` operation on a [form].
  Future<Content> readResource(Form form);

  /// Requests the client to perform a `writeproperty` operation on a [form]
  /// using the given [content].
  Future<void> writeResource(Form form, Content content);

  /// Requests the client to perform an `invokeaction` operation on a [form]
  /// using the given [content].
  Future<Content> invokeResource(Form form, Content content);

  /// Requests the client to perform a `subscribeproperty` operation on a
  /// [form].
  Future<Subscription> subscribeResource(
      Form form,
      void Function() deregisterObservation,
      void Function(Content content) next,
      void Function(Exception error)? error,
      void Function()? complete);

  /// Defines the security definitions used by the client.
  // TODO(falko17): Document return parameter
  bool setSecurity(List<SecurityScheme> metaData, Credentials? credentials);
}
