// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "../security/oauth2_security_scheme.dart";
import "credentials.dart";

/// [Credentials] used for the [OAuth2SecurityScheme].
final class OAuth2Credentials extends Credentials {
  /// Constructor.
  const OAuth2Credentials({
    this.secret,
    this.credentialsJson,
  });

  /// The optional secret for these [OAuth2Credentials].
  final String? secret;

  /// A JSON string representation of OAuth2 credentials.
  ///
  /// Used to store obtained credentials from an authorization server.
  final String? credentialsJson;
}
