// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "../security/basic_security_scheme.dart";
import "credentials.dart";

/// [Credentials] used for the [BasicSecurityScheme].
///
/// Provides an unencrypted [username] and [password] combination.
final class BasicCredentials extends Credentials {
  /// Constructor.
  const BasicCredentials(this.username, this.password);

  /// The [username] associated with these [BasicCredentials].
  final String username;

  /// The [password] associated with these [BasicCredentials].
  final String password;
}
