// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../../definitions/security/apikey_security_scheme.dart';

import 'credentials.dart';

/// [Credentials] used for the `APIKeySecurityScheme`.
class ApiKeyCredentials extends Credentials<ApiKeySecurityScheme> {
  /// The [apiKey] associated with these [ApiKeyCredentials].
  String apiKey;

  /// Constructor.
  ApiKeyCredentials(this.apiKey) : super("apikey");
}
