// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:io";

/// Extension that makes it easier to handle [Uri]s which potentially contain
/// [InternetAddress]es.
extension InternetAddressMethodExtension on Uri {
  /// Checks whether the host of this [Uri] is a multicast [InternetAddress].
  bool get hasMulticastAddress {
    return InternetAddress.tryParse(host)?.isMulticast ?? false;
  }
}
