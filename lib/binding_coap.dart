// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

/// Protocol binding for the Constrained Application Protocol (CoAP). Follows
/// the [WoT Binding Templates Specification][spec link] for CoAP.
///
/// [spec link]: https://www.w3.org/TR/wot-binding-templates/
library binding_coap;

export "package:coap/coap.dart"
    show Certificate, DerCertificate, PemCertificate;

export "src/binding_coap/coap_client_factory.dart";
export "src/binding_coap/coap_config.dart";
export "src/binding_coap/coap_server.dart";
