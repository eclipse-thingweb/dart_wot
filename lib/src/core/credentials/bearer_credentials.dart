// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../../definitions/security/bearer_security_scheme.dart';

import 'credentials.dart';

/// [Credentials] used for the `BearerSecurityScheme`.
class BearerCredentials extends Credentials<BearerSecurityScheme> {
  /// The [token] associated with these [BearerCredentials].
  String token;

  /// Constructor.
  BearerCredentials(this.token) : super("bearer");
}
