// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import 'package:dart_wot/src/core/content.dart';
import 'package:dart_wot/src/definitions/form.dart';
import 'package:dart_wot/src/definitions/security_scheme.dart';

import '../credentials.dart';
import '../subscription.dart';

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
      void Function(Content content) next,
      void Function(Exception error)? error,
      void Function()? complete);

  /// Requests the client to perform a `unsubscribeproperty` operation on a
  /// [form].
  // TODO(JKRhb): Unclear if this should rather be an unlinkResource method.
  Future<Content> unsubscribeResource(Form form);

  /// Defines the security definitions used by the client.
  // TODO(falko17): Document return parameter
  bool setSecurity(List<SecurityScheme> metaData, Credentials? credentials);
}
