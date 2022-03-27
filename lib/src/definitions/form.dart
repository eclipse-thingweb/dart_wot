// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'credentials/credentials.dart';
import 'expected_response.dart';
import 'security/security_scheme.dart';
import 'thing_description.dart';

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
  String contentType = "application/json";

  /// The list of [security] definitions applied to this [Form].
  List<String>? security;

  /// A list of OAuth2 scopes that are supposed to be used with this [Form].
  List<String>? scopes;

  /// The [response] a consumer can expect from interacting with this [Form].
  ExpectedResponse? response;

  /// Additional fields collected during the parsing of a JSON object.
  final Map<String, dynamic> additionalFields = <String, dynamic>{};

  /// The [securityDefinitions] associated with this [Form].
  ///
  /// Used by augmented [Form]s.
  Map<String, SecurityScheme> securityDefinitions = {};

  /// The credentials associated with this [Form].
  ///
  /// Used by augmented [Form]s.
  // TODO(JKRhb): Move to an agumented Form class.
  List<Credentials> credentials = [];

  final List<String> _parsedJsonFields = [];

  /// Creates a new [Form] object.
  ///
  /// An [href] has to be provided. A [contentType] is optional.
  Form(this.href,
      {this.contentType = "application/json",
      this.subprotocol,
      this.security,
      this.scopes,
      this.response,
      Map<String, dynamic>? additionalFields}) {
    if (additionalFields != null) {
      this.additionalFields.addAll(additionalFields);
    }
  }

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
      } else if (jsonOp is List<dynamic>) {
        op = jsonOp.whereType<String>().toList();
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
      } else if (jsonSecurity is List<dynamic>) {
        security = jsonSecurity.whereType<String>().toList();
      }
    }

    if (json["scopes"] != null) {
      final dynamic jsonScopes = _getJsonValue(json, "scopes");
      if (jsonScopes is String) {
        scopes = [jsonScopes];
      } else if (jsonScopes is List<dynamic>) {
        scopes = jsonScopes.whereType<String>().toList();
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
    // TODO(JKRhb): Make deep copies of security, scopes, and response.
    final copiedForm = Form(href)
      ..contentType = contentType
      ..op = op
      ..subprotocol = subprotocol
      ..securityDefinitions = securityDefinitions
      ..security = security
      ..scopes = scopes
      ..response = response;
    return copiedForm;
  }

  static String _augmentHref(Uri href, ThingDescription thingDescription) {
    final base = thingDescription.base;
    if (base == null) {
      throw ArgumentError(
          "Relative URI given for affordance form but no base provided!");
    }
    final parsedBaseUri = Uri.parse(base);
    return href
        .replace(
          scheme: parsedBaseUri.scheme,
          host: parsedBaseUri.host,
          port: parsedBaseUri.port,
        )
        .toString();
  }

  /// Copies and augments this [Form] with additional information.
  ///
  /// Converts relative [Form] URLs into absolute ones using the `base` field of
  /// a [ThingDescription] and links concrete [SecurityScheme]s to it.
  Form augment(ThingDescription thingDescription) {
    final Form augmentedForm = copy();
    final parsedHref = Uri.parse(href);
    if (!parsedHref.isAbsolute) {
      augmentedForm.href = _augmentHref(parsedHref, thingDescription);
    }
    final security = augmentedForm.security ?? thingDescription.security;
    thingDescription.securityDefinitions.entries
        .where((element) => security.contains(element.key))
        .forEach((element) {
      augmentedForm.securityDefinitions[element.key] = element.value;
    });
    return augmentedForm;
  }

  /// Associates [credentials] with [securityDefinitions] used by this [Form].
  void updateCredentials(
      Map<String, Credentials<SecurityScheme>>? credentials) {
    final definitionKeys = securityDefinitions.keys;
    this.credentials = credentials?.entries
            .where((element) => definitionKeys.contains(element.key))
            .map((element) => element.value)
            .toList(growable: false) ??
        List.empty();
  }
}
