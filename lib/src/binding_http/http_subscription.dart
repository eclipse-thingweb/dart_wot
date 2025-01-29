// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:convert";

import "package:sse_channel/sse_channel.dart";

import "../../core.dart";

/// A [ProtocolSubscription] for supporting server-sent events.
final class HttpSseSubscription extends ProtocolSubscription {
  /// Constructor
  HttpSseSubscription(
    AugmentedForm form,
    super._complete, {
    required void Function(Content content) next,
    void Function(Exception error)? onError,
    void Function()? complete,
  })  : _active = true,
        _sseChannel = SseChannel.connect(form.resolvedHref) {
    _sseChannel.stream.listen(
      (data) {
        if (data is! String) {
          return;
        }
        next(
          Content(form.contentType, Stream.fromIterable([utf8.encode(data)])),
        );
      },
      onError: (error) {
        if (error is! Exception) {
          return;
        }

        onError?.call(error);
      },
      onDone: complete,
    );
  }

  final SseChannel _sseChannel;

  bool _active;

  @override
  bool get active => _active;

  @override
  Future<void> stop({
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  }) async {
    if (!_active) {
      return;
    }
    _active = false;

    await _sseChannel.sink.close();
    await super
        .stop(formIndex: formIndex, uriVariables: uriVariables, data: data);
  }
}
