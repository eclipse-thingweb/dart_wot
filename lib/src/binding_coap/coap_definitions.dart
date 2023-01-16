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
  get(RequestMethod.get),

  /// Corresponds with the PUT request method.
  put(RequestMethod.put),

  /// Corresponds with the POST request method.
  post(RequestMethod.post),

  /// Corresponds with the DELETE request method.
  delete(RequestMethod.delete),

  /// Corresponds with the FETCH request method.
  fetch(RequestMethod.fetch),

  /// Corresponds with the PATCH request method.
  patch(RequestMethod.patch),

  /// Corresponds with the iPATCH request method.
  ipatch(RequestMethod.ipatch);

  /// Constructor
  const CoapRequestMethod(this.code);

  /// The numeric code of this [CoapRequestMethod].
  final RequestMethod code;

  static final _registry = HashMap.fromEntries(
    values.map((e) => MapEntry(e.code.description, e)),
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
