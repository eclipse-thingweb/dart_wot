// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dcaf/dcaf.dart";

import "../security/ace_security_scheme.dart";
import "credentials.dart";

/// [Credentials] used for the [AceSecurityScheme].
final class AceCredentials extends Credentials {
  /// Constructor.
  const AceCredentials(this.accessToken);

  /// The access token associated with these [AceCredentials] in serialized
  /// form.
  final AccessTokenResponse accessToken;
}
