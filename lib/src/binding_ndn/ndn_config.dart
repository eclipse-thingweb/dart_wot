// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:meta/meta.dart";

import "ndn_consumer.dart";

@immutable

/// Configuration class used by [NdnClient]s.
class NdnConfig {
  ///
  const NdnConfig({
    this.faceUri,
  });

  /// [Uri] of the local NDN Forwarding Daemon (NFD).
  ///
  /// If `null`, then the default [Uri] will be used, connecting the
  /// [NdnClient] to the NFD via a Unix Socket.
  final Uri? faceUri;
}
