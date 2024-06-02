// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

/// Provides Thing Description and Thing Model Definitions that follow the
/// [WoT Thing Description Specification][spec link] as well as additional data
/// models for passing credentials to the Scripting API implementation.
///
/// [spec link]: https://www.w3.org/TR/wot-thing-description11/
library definitions;

export "package:dcaf/dcaf.dart" show AuthServerRequestCreationHint;

export "definitions/additional_expected_response.dart";

export "definitions/credentials/ace_credentials.dart";
export "definitions/credentials/apikey_credentials.dart";
export "definitions/credentials/basic_credentials.dart";
export "definitions/credentials/bearer_credentials.dart";
export "definitions/credentials/callbacks.dart";
export "definitions/credentials/credentials.dart";
export "definitions/credentials/digest_credentials.dart";
export "definitions/credentials/oauth2_credentials.dart";
export "definitions/credentials/psk_credentials.dart";

export "definitions/data_schema.dart";
export "definitions/expected_response.dart";
export "definitions/form.dart";
export "definitions/interaction_affordances/interaction_affordance.dart";
export "definitions/link.dart";
export "definitions/operation_type.dart";
export "definitions/security/ace_security_scheme.dart";
export "definitions/security/apikey_security_scheme.dart";
export "definitions/security/auto_security_scheme.dart";
export "definitions/security/basic_security_scheme.dart";
export "definitions/security/bearer_security_scheme.dart";
export "definitions/security/combo_security_scheme.dart";
export "definitions/security/digest_security_scheme.dart";
export "definitions/security/no_security_scheme.dart";
export "definitions/security/oauth2_security_scheme.dart";
export "definitions/security/psk_security_scheme.dart";
export "definitions/security/security_scheme.dart";
export "definitions/thing_description.dart";
export "definitions/thing_model.dart";
