// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../../definitions/security/basic_security_scheme.dart';

import 'credentials.dart';

/// [Credentials] used for the `BasicSecurityScheme`.
///
/// Provides an unencrypted [username] and [password] combination.
class BasicCredentials extends Credentials<BasicSecurityScheme> {
  /// The [username] associated with these [BasicCredentials].
  String username;

  /// The [password] associated with these [BasicCredentials].
  String password;

  /// Constructor.
  BasicCredentials(this.username, this.password) : super("basic");
}
