// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "../../core.dart";

import "http_client.dart";
import "http_config.dart";

/// A [ProtocolClientFactory] that produces HTTP and HTTPS clients.
final class HttpClientFactory implements ProtocolClientFactory {
  /// Creates a new [HttpClientFactory] based on an optional [HttpConfig].
  HttpClientFactory({
    AsyncClientSecurityCallback<BasicCredentials>? basicCredentialsCallback,
    AsyncClientSecurityCallback<BearerCredentials>? bearerCredentialsCallback,
  })  : _basicCredentialsCallback = basicCredentialsCallback,
        _bearerCredentialsCallback = bearerCredentialsCallback;

  final AsyncClientSecurityCallback<BasicCredentials>?
      _basicCredentialsCallback;

  final AsyncClientSecurityCallback<BearerCredentials>?
      _bearerCredentialsCallback;

  @override
  Set<String> get schemes => {"http", "https"};

  @override
  bool destroy() {
    return true;
  }

  @override
  ProtocolClient createClient() => HttpClient(
        basicCredentialsCallback: _basicCredentialsCallback,
        bearerCredentialsCallback: _bearerCredentialsCallback,
      );

  @override
  bool init() {
    return true;
  }

  @override
  bool supportsOperation(OperationType operationType, String? subprotocol) {
    const unsupportedOperations = [
      OperationType.observeproperty,
      OperationType.unobserveproperty,
      OperationType.subscribeevent,
      OperationType.unsubscribeevent,
    ];

    if (unsupportedOperations.contains(operationType)) {
      return false;
    }

    if (subprotocol != null) {
      return false;
    }

    return true;
  }
}
