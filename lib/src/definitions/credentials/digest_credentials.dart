// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../security/digest_security_scheme.dart';
import 'credentials.dart';

/// [Credentials] used for the [DigestSecurityScheme].
class DigestCredentials extends Credentials<DigestSecurityScheme> {
  /// The [username] associated with these [DigestCredentials].
  String username;

  /// The [password] associated with these [DigestCredentials].
  String password;

  /// Constructor.
  DigestCredentials(this.username, this.password) : super("digest");
}
