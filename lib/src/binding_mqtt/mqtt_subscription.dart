// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../core/content.dart';
import '../definitions/form.dart';
import '../scripting_api/interaction_options.dart';
import '../scripting_api/subscription.dart' as scripting_api;

/// [scripting_api.Subscription] for the MQTT protocol.
class MqttSubscription implements scripting_api.Subscription {
  /// Constructor.
  MqttSubscription(
    this._form,
    this._client,
    this._complete, {
    required void Function(Content content) next,
    void Function(Exception error)? error,
  }) : _active = true {
    final updates = _client.updates;

    if (updates == null) {
      throw ArgumentError.notNull('client.updates');
    }

    // TODO: Check if this needs to be cleaned up somehow
    updates.listen(
      (messages) {
        for (final message in messages) {
          final publishedMessage = message.payload as MqttPublishMessage;
          final payload = publishedMessage.payload.message;

          next(Content(_form.contentType, Stream.value(payload)));
        }
      },
      onError: (error_) {
        if (error == null || error_ is! Exception) {
          return;
        }
        error(error_);
      },
      cancelOnError: false,
      onDone: stop,
    );
  }

  final Form _form;

  final MqttServerClient _client;

  bool _active = true;

  final void Function() _complete;

  @override
  bool get active => _active;

  @override
  Future<void> stop([InteractionOptions? options]) async {
    _client.disconnect();
    _active = false;
    _complete();
  }
}
