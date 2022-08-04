// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:collection';

import 'package:coap/coap.dart';
import 'package:curie/curie.dart';

import '../definitions/form.dart';

/// [PrefixMapping] for expanding CoAP Vocabulary terms from compact IRIs.
final coapPrefixMapping =
    PrefixMapping(defaultPrefixValue: 'http://www.example.org/coap-binding#');

/// Defines the available CoAP request methods.
enum CoapRequestMethod {
  /// Corresponds with the GET request method.
  get(CoapCode.get, 'GET'),

  /// Corresponds with the PUT request method.
  put(CoapCode.put, 'PUT'),

  /// Corresponds with the POST request method.
  post(CoapCode.post, 'POST'),

  /// Corresponds with the DELETE request method.
  delete(CoapCode.delete, 'DELETE'),

  /// Corresponds with the FETCH request method.
  fetch(CoapCode.notSet),

  /// Corresponds with the PATCH request method.
  patch(CoapCode.notSet),

  /// Corresponds with the iPATCH request method.
  ipatch(CoapCode.notSet);

  /// Constructor
  const CoapRequestMethod(this.code, [this.stringValue]);

  /// The numeric code of this [CoapRequestMethod].
  final int code;

  /// The string value of this request method value (e.g., `GET` or `POST`).
  final String? stringValue;

  static final _registry = HashMap.fromEntries(
    values
        .where((element) => element.stringValue != null)
        .map((e) => MapEntry(e.stringValue, e)),
  );

  static CoapRequestMethod? _fromString(String stringValue) =>
      _registry[stringValue];

  /// Determines the [CoapRequestMethod] to use based on a given [form].
  static CoapRequestMethod? fromForm(Form form) {
    final curieString =
        coapPrefixMapping.expandCurie(Curie(reference: 'method'));
    final dynamic formDefinition = form.additionalFields[curieString];

    if (formDefinition is! String) {
      return null;
    }

    return CoapRequestMethod._fromString(formDefinition);
  }
}

/// Enumeration of available CoAP subprotocols.
enum CoapSubprotocol {
  /// Subprotocol for observing CoAP resources.
  observe,
}
