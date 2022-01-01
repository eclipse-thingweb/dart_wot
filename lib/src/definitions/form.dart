// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import 'expected_response.dart';

/// Contains the information needed for performing interactions with a Thing.
class Form {
  /// The [href] pointing to the resource.
  ///
  /// Can be a relative or absolute URI.
  late String href;

  /// The subprotocol that is used with this [Form].
  String? subprotocol;

  /// The operation types supported by this [Form].
  List<String>? op;

  /// The [contentType] supported by this [Form].
  String? contentType;

  /// The list of [security] definitions applied to this [Form].
  List<String>? security;

  /// A list of OAuth2 scopes that are supposed to be used with this [Form].
  List<String>? scopes;

  /// The [response] a consumer can expect from interacting with this [Form].
  ExpectedResponse? response;

  /// Additional fields collected during the parsing of a JSON object.
  final Map<String, dynamic> additionalFields = <String, dynamic>{};

  final List<String> _parsedJsonFields = [];

  /// Creates a new [Form] object.
  ///
  /// An [href] has to be provided. A [contentType] is optional.
  Form(this.href, [this.contentType]);

  /// Creates a new [Form] from a [json] object.
  Form.fromJson(Map<String, dynamic> json) {
    // TODO(JKRhb): Check if this can be refactored
    if (json["href"] is String) {
      _parsedJsonFields.add("href");
      href = json["href"] as String;
    } else {
      // [href] *must* be initialized.
      throw ArgumentError("'href' field must exist as a string.", "formJson");
    }

    if (json["subprotocol"] is String) {
      _parsedJsonFields.add("subprotocol");
      subprotocol = json["subprotocol"] as String;
    }

    if (json["op"] != null) {
      final dynamic jsonOp = _getJsonValue(json, "op");
      if (jsonOp is String) {
        op = [jsonOp];
      } else if (jsonOp is List<String>) {
        op = jsonOp;
      }
    }

    if (json["contentType"] != null) {
      final dynamic jsonContentType = _getJsonValue(json, "contentType");
      if (jsonContentType is String) {
        contentType = jsonContentType;
      }
    }

    if (json["security"] != null) {
      final dynamic jsonSecurity = _getJsonValue(json, "security");
      if (jsonSecurity is String) {
        security = [jsonSecurity];
      } else if (jsonSecurity is List<String>) {
        security = jsonSecurity;
      }
    }

    if (json["scopes"] != null) {
      final dynamic jsonScopes = _getJsonValue(json, "scopes");
      if (jsonScopes is String) {
        scopes = [jsonScopes];
      } else if (jsonScopes is List<String>) {
        scopes = jsonScopes;
      }
    }

    if (json["response"] != null) {
      final dynamic jsonResponse = _getJsonValue(json, "response");
      if (jsonResponse is Map<String, dynamic>) {
        response = ExpectedResponse.fromJson(jsonResponse);
      }
    }

    _addAdditionalFields(json);
  }

  dynamic _getJsonValue(Map<String, dynamic> formJson, String key) {
    _parsedJsonFields.add(key);
    return formJson[key];
  }

  void _addAdditionalFields(Map<String, dynamic> formJson) {
    for (final entry in formJson.entries) {
      if (!_parsedJsonFields.contains(entry.key)) {
        additionalFields[entry.key] = entry.value;
      }
    }
  }

  /// Creates a deep copy of this [Form].
  Form copy() {
    // TODO(JKRhb): Copy the other fields as well
    final copiedForm = Form(href)..contentType = contentType;
    return copiedForm;
  }

  /// Copies and augments this [Form] with additional information.
  ///
  /// At the moment, only the [base] of a Thing Description is used for turning
  /// relative [Form] URLs into absolute ones.
  Form augment(final String? base) {
    final Form augmentedForm = copy();
    var parsedHref = Uri.parse(href);
    if (!parsedHref.isAbsolute) {
      if (base == null) {
        throw ArgumentError(
            "Relative URI given for affordance form but no base provided!");
      }
      final parsedBaseUri = Uri.parse(base);
      parsedHref = parsedHref.replace(
        scheme: parsedBaseUri.scheme,
        host: parsedBaseUri.host,
        port: parsedBaseUri.port,
      );
      augmentedForm.href = parsedHref.toString();
    }
    return augmentedForm;
  }
}
