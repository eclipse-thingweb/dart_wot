// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../../definitions/security/bearer_security_scheme.dart';

import 'credentials.dart';

/// [Credentials] used for the [BearerSecurityScheme].
final class BearerCredentials extends Credentials {
  /// Constructor.
  BearerCredentials(this.token);

  /// The [token] associated with these [BearerCredentials].
  String token;
}
