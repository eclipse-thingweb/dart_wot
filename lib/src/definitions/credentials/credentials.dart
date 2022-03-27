// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../security/security_scheme.dart';

/// Base class used for defining credentials for Thing Interactions.
abstract class Credentials<T extends SecurityScheme> {
  /// The name of the SecurityScheme these [Credentials] are associated with.
  final String securitySchemeType;

  /// The concrete [SecurityScheme] linked to these [Credentials].
  T? securityScheme;

  /// Constructor.
  Credentials(this.securitySchemeType);
}
