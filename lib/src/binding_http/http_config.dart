// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:meta/meta.dart";

/// Allows for configuring the behavior of HTTP clients and servers.
class HttpConfig {
  /// Creates a new [HttpConfig] object.
  HttpConfig({this.port, this.secure});

  /// Custom port number that should be used by a server.
  ///
  /// Defaults to 80 for HTTP and 443 for HTTPS.
  int? port;

  /// Indicates if the client or server should use HTTPS.
  bool? secure;
}

/// Configuration parameters specific to dart_wot's HTTP Client implementation.
@immutable
class HttpClientConfig {
  /// Creates a new [HttpClientConfig] object.
  const HttpClientConfig({
    this.trustedCertificates,
  });

  /// List of trusted certificates that will be added to the security contexts
  /// of newly created HTTP clients.
  ///
  /// Certificates can either use the PEM or or the PKCS12 format, the latter of
  /// which also supports the use of an optional password.
  final List<({List<int> certificate, String? password})>? trustedCertificates;
}
