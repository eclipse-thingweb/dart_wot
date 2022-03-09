// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../credentials/credentials.dart';

/// Interface to ensure that a given `SecurityScheme` has a [credentials] field.
abstract class CredentialsScheme {
  /// The credentials assigned to this [CredentialsScheme].
  Credentials? get credentials;
}
