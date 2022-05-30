// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../../definitions/security/psk_security_scheme.dart';
import 'credentials.dart';

/// [Credentials] used for the [PskSecurityScheme].
class PskCredentials extends Credentials<PskSecurityScheme> {
  /// The [identity] associated with these [PskCredentials].
  ///
  /// May be omitted if the corresponding Security Definition in the TD already
  /// specifies an identity.
  final String identity;

  /// The [preSharedKey] associated with these [PskCredentials].
  final String preSharedKey;

  /// Constructor.
  PskCredentials({required this.preSharedKey, required this.identity})
      : super("psk");
}
