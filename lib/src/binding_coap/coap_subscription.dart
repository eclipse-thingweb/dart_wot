// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:coap/coap.dart";

import "../../core.dart";

/// [ProtocolSubscription] to a CoAP resource, based on the observe option
/// ([RFC 7641]).
///
/// [RFC 7641]: https://datatracker.ietf.org/doc/html/rfc7641
final class CoapSubscription extends ProtocolSubscription {
  /// Constructor
  CoapSubscription(
    this._coapClient,
    this._observeClientRelation,
    super._complete,
  ) : _active = true;

  final CoapClient _coapClient;

  final CoapObserveClientRelation? _observeClientRelation;

  bool _active;

  @override
  bool get active => _active;

  @override
  Future<void> stop({
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  }) async {
    if (!_active) {
      return;
    }
    _active = false;

    final observeClientRelation = _observeClientRelation;
    if (observeClientRelation != null) {
      await _coapClient.cancelObserveProactive(observeClientRelation);
    }
    _coapClient.close();
    await super
        .stop(formIndex: formIndex, uriVariables: uriVariables, data: data);
  }
}
