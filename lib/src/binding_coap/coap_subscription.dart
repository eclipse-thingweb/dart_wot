// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:coap/coap.dart';

import '../scripting_api/interaction_options.dart';
import '../scripting_api/subscription.dart';

/// [Subscription] to a CoAP resource, based on the observe option ([RFC 7641]).
///
/// [RFC 7641]: https://datatracker.ietf.org/doc/html/rfc7641
class CoapSubscription implements Subscription {
  /// Constructor
  CoapSubscription(
    this._coapClient,
    this._observeClientRelation,
    this._complete,
  ) : _active = true;

  final CoapClient _coapClient;

  final CoapObserveClientRelation? _observeClientRelation;

  bool _active;

  @override
  bool get active => _active;

  /// Callback used to pass by the servient that is used to signal it that an
  /// observation has been cancelled.
  final void Function() _complete;

  @override
  Future<void> stop([InteractionOptions? options]) async {
    if (!_active) {
      return;
    }
    _active = false;

    final observeClientRelation = _observeClientRelation;
    if (observeClientRelation != null) {
      await _coapClient.cancelObserveProactive(observeClientRelation);
    }
    _coapClient.close();
    _complete();
  }
}
