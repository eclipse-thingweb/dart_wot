// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:collection/collection.dart";
import "package:json_schema/json_schema.dart";
import "package:meta/meta.dart";
import "package:uri/uri.dart";

import "../definitions/additional_expected_response.dart";
import "../definitions/expected_response.dart";
import "../definitions/form.dart";
import "../definitions/interaction_affordances/interaction_affordance.dart";
import "../definitions/operation_type.dart";
import "../definitions/security/security_scheme.dart";
import "../definitions/thing_description.dart";
import "../definitions/validation/validation_exception.dart";

/// A [Form] augmented with information from its asscociated [_thingDescription]
/// and [_interactionAffordance].
@immutable
final class AugmentedForm implements Form {
  /// Creates a new augmented [Form].
  const AugmentedForm(
    this._form,
    this._interactionAffordance,
    this._thingDescription,
    this._userProvidedUriVariables,
  );

  final Form _form;

  final ThingDescription _thingDescription;

  final InteractionAffordance _interactionAffordance;

  final Map<String, Object>? _userProvidedUriVariables;

  /// The identifier of the [_thingDescription] associated with this form.
  String get tdIdentifier => _thingDescription.identifier;

  @override
  Map<String, dynamic> get additionalFields => _form.additionalFields;

  @override
  List<AdditionalExpectedResponse>? get additionalResponses =>
      _form.additionalResponses;

  @override
  String? get contentCoding => _form.contentCoding;

  @override
  String get contentType => _form.contentType;

  @override
  Uri get href {
    final baseUri = _thingDescription.base;

    if (baseUri != null) {
      return baseUri.resolveUri(_form.href);
    }

    return _form.href;
  }

  @override
  List<OperationType> get op =>
      _form.op ?? OperationType.defaultOpValues(_interactionAffordance);

  @override
  ExpectedResponse? get response => _form.response;

  @override
  List<String>? get scopes => _form.scopes;

  @override
  List<String> get security => _form.security ?? _thingDescription.security;

  @override
  String? get subprotocol => _form.subprotocol;

  /// The computed [List] of [SecurityScheme]s associated with this form.
  ///
  /// The list is derived from the [_thingDescription] and the [security] keys
  /// defined for the form.
  List<SecurityScheme> get securityDefinitions =>
      _thingDescription.securityDefinitions.entries
          .where(
            (securityDefinition) => security.contains(securityDefinition.key),
          )
          .map((securityDefinition) => securityDefinition.value)
          .toList();

  List<String> _filterUriVariables(Uri href) {
    final regex = RegExp("{[?+#./;&]?([^}]*)}");
    final decodedUri = Uri.decodeFull(href.toString());
    return regex
        .allMatches(decodedUri)
        .map((e) => e.group(1))
        .whereType<String>()
        .map((e) => e.split(","))
        .flattened
        .toList(growable: false);
  }

  /// Resolves all [_userProvidedUriVariables] in this [Form] and returns the
  /// resulting [Uri].
  Uri get resolvedHref {
    final hrefUriVariables = _filterUriVariables(href);

    if (hrefUriVariables.isEmpty) {
      return href;
    }

    final Map<String, Object> affordanceUriVariables = {
      ..._thingDescription.uriVariables ?? {},
      ..._interactionAffordance.uriVariables ?? {},
    };

    final userProvidedUriVariables = _userProvidedUriVariables;
    if (userProvidedUriVariables != null) {
      _validateUriVariables(
        hrefUriVariables,
        affordanceUriVariables,
        userProvidedUriVariables,
      );
    }

    // As "{" and "}" are "percent encoded" due to Uri.parse(), we need to
    // revert the encoding first before we can insert the values.
    final decodedHref = Uri.decodeFull(href.toString());

    final expandedHref =
        UriTemplate(decodedHref).expand(userProvidedUriVariables ?? {});
    return Uri.parse(expandedHref);
  }

  void _validateUriVariables(
    List<String> uriVariablesInHref,
    Map<String, Object> affordanceUriVariables,
    Map<String, Object> userProvidedUriVariables,
  ) {
    final uncoveredHrefUriVariables = uriVariablesInHref
        .where((element) => !affordanceUriVariables.containsKey(element));

    if (uncoveredHrefUriVariables.isNotEmpty) {
      throw ValidationException(
          "The following URI template variables defined in the form's href "
          "but are not covered by a uriVariable entry at the TD or affordance "
          "level: ${uncoveredHrefUriVariables.join(", ")}.");
    }

    final missingTdLevelUserInput = uriVariablesInHref.where(
      (uriVariableName) =>
          !userProvidedUriVariables.containsKey(uriVariableName),
    );

    if (missingTdLevelUserInput.isNotEmpty) {
      throw UriVariableException(
        "The following URI template variables defined at the TD level are not "
        "covered by the values provided by the user: "
        "${missingTdLevelUserInput.join(", ")}. "
        "Values for the following variables were received: "
        "${userProvidedUriVariables.keys.join(", ")}.",
      );
    }

    // We now assert that all user provided values comply to the Schema
    // definition in the TD.
    for (final affordanceUriVariable in affordanceUriVariables.entries) {
      final key = affordanceUriVariable.key;
      final value = affordanceUriVariable.value;

      final schema = JsonSchema.create(value);
      final result = schema.validate(userProvidedUriVariables[key]);

      if (!result.isValid) {
        throw ValidationException("Invalid type for URI variable $key");
      }
    }
  }
}

/// This [Exception] is thrown when [URI variables] are being used in the [Form]
/// of a TD but no (valid) values were provided.
///
/// [URI variables]: https://www.w3.org/TR/wot-thing-description11/#form-uriVariables
class UriVariableException implements Exception {
  /// Constructor.
  UriVariableException(this.message);

  /// The error [message].
  final String message;

  @override
  String toString() {
    return "UriVariableException: $message";
  }
}
