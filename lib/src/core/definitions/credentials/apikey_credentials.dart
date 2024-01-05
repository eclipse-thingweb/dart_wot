// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "../security/apikey_security_scheme.dart";
import "credentials.dart";

/// [Credentials] used for the [ApiKeySecurityScheme].
final class ApiKeyCredentials extends Credentials {
  /// Constructor.
  const ApiKeyCredentials(this.apiKey);

  /// The [apiKey] associated with these [ApiKeyCredentials].
  final String apiKey;
}
