// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:meta/meta.dart";

import "../../core.dart";
import "ndn_config.dart";
import "ndn_consumer.dart";

/// A [ProtocolClientFactory] that produces
@immutable
class NdnClientFactory implements ProtocolClientFactory {
  /// Creates a new [ProtocolClientFactory] from an [ndnConfig].
  const NdnClientFactory({
    this.ndnConfig = const NdnConfig(),
  });

  /// The [NdnConfig] acting as the blueprint for creating
  final NdnConfig ndnConfig;

  @override
  Future<ProtocolClient> createClient() async {
    return NdnClient.create(ndnConfig);
  }

  @override
  bool destroy() {
    return true;
  }

  @override
  bool init() {
    return true;
  }

  @override
  Set<String> get schemes => {"ndn"};

  @override
  bool supportsOperation(OperationType operationType, String? subprotocol) {
    return operationType == OperationType.readproperty && subprotocol == null;
  }
}
