// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "../security/digest_security_scheme.dart";
import "credentials.dart";

/// [Credentials] used for the [DigestSecurityScheme].
final class DigestCredentials extends Credentials {
  /// Constructor.
  const DigestCredentials(this.username, this.password);

  /// The [username] associated with these [DigestCredentials].
  final String username;

  /// The [password] associated with these [DigestCredentials].
  final String password;
}
