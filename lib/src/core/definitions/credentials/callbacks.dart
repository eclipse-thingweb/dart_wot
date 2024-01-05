// Copyright 2023 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:dcaf/dcaf.dart";

import "../../implementation.dart";
import "../form.dart";
import "ace_credentials.dart";
import "credentials.dart";
import "psk_credentials.dart";

/// Function signature for a synchronous callback for providing client
/// [PskCredentials] at runtime.
///
/// If no credentials can be retrieved, a `null` value should be returned (which
/// will lead to the throw of an exception in the respective binding). This
/// behavior might change in future versions of `dart_wot`.
///
/// Users can retrieve or generate credentials based on the endpoint's [uri] or
/// an [identityHint] that might be given by the server. In the case of
/// interactions, the corresponding [Form] is also provided.
typedef ClientPskCallback = PskCredentials? Function(
  Uri uri,
  Form? form,
  String? identityHint,
);

/// Function signature for an asynchronous callback for providing client
/// [AceCredentials] at runtime, based on an optional [creationHint]
/// given by the Resource Server. This creation hint has to be parsed by the
/// library user.
///
/// If a request with an access token has failed before, leading to an
/// "Unauthorized" response, the [invalidAceCredentials] from the previous
/// request are returned as an additional parameter.
typedef AceSecurityCallback = Future<AceCredentials?> Function(
  Uri uri,
  Form? form,
  AuthServerRequestCreationHint? creationHint,
  AceCredentials? invalidAceCredentials,
);

/// Function signature for an asynchronous callback for providing client
/// [Credentials] at runtime.
///
/// Users can retrieve or generate credentials based on the endpoint's [uri].
/// In the case of interactions, the corresponding [Form] is also retrieved.
///
/// If no credentials can be retrieved, a `null` value should be returned (which
/// will lead to the throw of an exception in the respective binding). This
/// behavior might change in future versions of `dart_wot`.
///
/// If the authorization/authentication fails with the given credentials, the
/// callback will be invoked again, containing the [invalidCredentials] as a set
/// argument.
///
/// This callback signature is currently only used for [PskCredentials] due to
/// implementation limititations, which do not allow for asynchronous callbacks.
typedef AsyncClientSecurityCallback<T extends Credentials> = Future<T?>
    Function(Uri uri, AugmentedForm? form, T? invalidCredentials);

/// Function signature for a synchronous callback retrieving server
/// [Credentials] by Thing [id] at runtime.
///
/// The returned hash map should map the keys of the individual Security
/// Definitions to concrete [Credentials].
///
/// Note: The exact API for retrieving server [Credentials] is still Work in
/// Progress.
typedef ServerSecurityCallback = Map<String, Credentials> Function(String id);
