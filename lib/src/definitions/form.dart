// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:curie/curie.dart';
import 'package:json_schema3/json_schema3.dart';
import 'package:uri/uri.dart';

import '../../dart_wot.dart';
import 'additional_expected_response.dart';
import 'expected_response.dart';
import 'extensions/json_parser.dart';
import 'interaction_affordances/action.dart';
import 'interaction_affordances/event.dart';
import 'interaction_affordances/interaction_affordance.dart';
import 'interaction_affordances/property.dart';
import 'operation_type.dart';
import 'security/security_scheme.dart';
import 'validation/validation_exception.dart';

/// Contains the information needed for performing interactions with a Thing.
class Form {
  /// Creates a new [Form] object.
  ///
  /// An [href] has to be provided. A [contentType] is optional.
  Form(
    this.href,
    this.thingDescription, {
    this.interactionAffordance,
    this.contentType = 'application/json',
    this.contentCoding,
    this.subprotocol,
    this.security,
    List<String>? op,
    this.scopes,
    this.response,
    this.additionalResponses,
    Map<String, dynamic>? additionalFields,
  })  : resolvedHref = _expandHref(href, thingDescription),
        securityDefinitions =
            _filterSecurityDefinitions(thingDescription, security),
        op = _setOpValue(interactionAffordance, op) {
    if (additionalFields != null) {
      this.additionalFields.addAll(additionalFields);
    }
  }

  /// Creates a new [Form] from a [json] object.
  factory Form.fromJson(
    Map<String, dynamic> json,
    PrefixMapping prefixMapping,
    ThingDescription thingDescription, [
    InteractionAffordance? interactionAffordance,
  ]) {
    final Set<String> parsedFields = {};
    final href = json.parseRequiredUriField('href', parsedFields);

    final subprotocol = json.parseField<String>('subprotocol', parsedFields);

    final List<String>? op = json.parseArrayField<String>('op', parsedFields);

    final contentType = json.parseField<String>('contentType', parsedFields) ??
        'application/json';

    final contentCoding =
        json.parseField<String>('contentCoding', parsedFields);

    final security = json.parseArrayField<String>('security', parsedFields);
    final scopes = json.parseArrayField<String>('scopes', parsedFields);
    final response = json.parseExpectedResponse(prefixMapping, parsedFields);

    final additionalResponses = json.parseAdditionalExpectedResponse(
      prefixMapping,
      contentType,
      parsedFields,
    );

    final additionalFields =
        json.parseAdditionalFields(prefixMapping, parsedFields);

    return Form(
      href,
      thingDescription,
      interactionAffordance: interactionAffordance,
      contentType: contentType,
      contentCoding: contentCoding,
      subprotocol: subprotocol,
      op: op,
      scopes: scopes,
      security: security,
      response: response,
      additionalResponses: additionalResponses,
      additionalFields: additionalFields,
    );
  }

  /// The [href] pointing to the resource.
  ///
  /// Can be a relative or absolute URI.
  final Uri href;

  /// An absolute [Uri], which is either the original [href] or a resolved
  /// version using the base [Uri] of the Thing Description.
  final Uri resolvedHref;

  /// The [SecurityScheme]s used by this [Form].
  final List<SecurityScheme> securityDefinitions;

  /// Reference to the [ThingDescription] containing this [Form].
  final ThingDescription thingDescription;

  /// Reference to the [InteractionAffordance] containing this [Form].
  ///
  /// Might be `null` if the [Form] is defined at the [ThingDescription] level.
  final InteractionAffordance? interactionAffordance;

  /// The subprotocol that is used with this [Form].
  String? subprotocol;

  /// The operation types supported by this [Form].
  final List<OperationType> op;

  /// The [contentType] supported by this [Form].
  String contentType = 'application/json';

  /// The content coding supported by this [Form].
  ///
  /// Content coding values indicate an encoding transformation that has been or
  /// can be applied to a representation.
  /// Content codings are primarily used to allow a representation to be
  /// compressed or otherwise usefully transformed without losing the identity
  /// of its underlying media type and without loss of information.
  /// Examples of content coding include "gzip", "deflate", etc.
  String? contentCoding;

  /// The list of [security] definitions applied to this [Form].
  List<String>? security;

  /// A list of OAuth2 scopes that are supposed to be used with this [Form].
  List<String>? scopes;

  /// The [response] a consumer can expect from interacting with this [Form].
  ExpectedResponse? response;

  /// This optional term can be used if additional expected responses are
  /// possible, e.g. for error reporting.
  ///
  /// Each additional response needs to be distinguished from others in some way
  /// (for example, by specifying a protocol-specific error code), and may also
  ///  have its own data schema.
  List<AdditionalExpectedResponse>? additionalResponses;

  /// Additional fields collected during the parsing of a JSON object.
  final Map<String, dynamic> additionalFields = {};

  static List<SecurityScheme> _filterSecurityDefinitions(
    ThingDescription thingDescription,
    List<String>? security,
  ) {
    final securityKeys = security ?? thingDescription.security;
    final securityDefinitions = thingDescription.securityDefinitions;

    return securityKeys.map((securityKey) {
      final securityDefinition = securityDefinitions[securityKey];

      if (securityDefinition == null) {
        throw ValidationException(
          'Form requires a security definition with '
          'key $securityKey, but the Thing Description does not define a '
          'security definition with such a key!',
        );
      }

      return securityDefinition;
    }).toList();
  }

  static Uri _expandHref(
    Uri href,
    ThingDescription thingDescription,
  ) {
    final base = thingDescription.base;
    if (href.isAbsolute) {
      return href;
    } else if (base != null) {
      return base.resolveUri(href);
    } else {
      throw ValidationException(
        "The form's $href is not an absolute URI, "
        'but the Thing Description does not provide a base field!',
      );
    }
  }

  static List<OperationType> _setOpValue(
    InteractionAffordance? interactionAffordance,
    List<String>? opStrings,
  ) {
    if (opStrings != null) {
      return opStrings.map(OperationType.fromString).toList();
    }

    if (interactionAffordance == null) {
      return [];
    }

    if (interactionAffordance is Action) {
      return [OperationType.invokeaction];
    } else if (interactionAffordance is Property) {
      final List<OperationType> op = [];
      if (!interactionAffordance.readOnly) {
        op.add(OperationType.readproperty);
      }
      if (!interactionAffordance.writeOnly) {
        op.add(OperationType.writeproperty);
      }
      return op;
    } else if (interactionAffordance is Event) {
      return [OperationType.subscribeevent, OperationType.unsubscribeevent];
    }

    throw StateError(
      'Encountered unknown InteractionAffordance '
      '${interactionAffordance.runtimeType}.',
    );
  }

  /// Creates a deep copy of this [Form].
  Form _copy(Uri newHref) {
    // TODO(JKRhb): Make deep copies of security, scopes, and response.
    final copiedForm = Form(
      newHref,
      thingDescription,
      interactionAffordance: interactionAffordance,
      op: op.map((opValue) => opValue.name).toList(),
      contentType: contentType,
      subprotocol: subprotocol,
      security: security,
      scopes: scopes,
      response: response,
      additionalFields: <String, dynamic>{}..addAll(additionalFields),
    );
    return copiedForm;
  }

  void _validateUriVariables(
    List<String> hrefUriVariables,
    Map<String, Object?> affordanceUriVariables,
    Map<String, Object?> uriVariables,
  ) {
    final missingTdDefinitions =
        hrefUriVariables.where((element) => !uriVariables.containsKey(element));

    if (missingTdDefinitions.isNotEmpty) {
      throw UriVariableException(
        '$missingTdDefinitions do not have defined '
        'uriVariables in the TD',
      );
    }

    final missingUserInput = hrefUriVariables
        .where((element) => !affordanceUriVariables.containsKey(element));

    if (missingUserInput.isNotEmpty) {
      throw UriVariableException(
        '$missingUserInput did not have defined '
        'Values in the provided InteractionOptions.',
      );
    }

    // We now assert that all user provided values comply to the Schema
    // definition in the TD.
    for (final affordanceUriVariable in affordanceUriVariables.entries) {
      final key = affordanceUriVariable.key;
      final value = affordanceUriVariable.value;

      if (value == null) {
        throw ValidationException('Missing schema for URI variable $key');
      }

      final schema = JsonSchema.create(value);
      final result = schema.validate(uriVariables[key]);

      if (!result.isValid) {
        throw ValidationException('Invalid type for URI variable $key');
      }
    }
  }

  List<String> _filterUriVariables(Uri href) {
    final regex = RegExp('{[?+#./;&]?([^}]*)}');
    final decodedUri = Uri.decodeFull(href.toString());
    return regex
        .allMatches(decodedUri)
        .map((e) => e.group(1))
        .whereType<String>()
        .toList(growable: false);
  }

  /// Resolves all [uriVariables] in this [Form] and creates a copy with an
  /// updated [resolvedHref].
  ///
  /// Returns [Null] if the [href] field does not use any URI variables.
  Form? resolveUriVariables(Map<String, Object>? uriVariables) {
    final hrefUriVariables = _filterUriVariables(resolvedHref);

    // Use global URI variables by default and override them with
    // affordance-level variables, if any
    final Map<String, Object?> affordanceUriVariables = {}
      ..addAll(thingDescription.uriVariables ?? {})
      ..addAll(interactionAffordance?.uriVariables ?? {});

    if (hrefUriVariables.isEmpty) {
      // The href uses no uriVariables, therefore we can abort all further
      // checks.
      return null;
    }

    if (affordanceUriVariables.isEmpty) {
      throw UriVariableException(
        'The Form href $href contains URI '
        'variables but the TD does not provide a uriVariables definition.',
      );
    }

    if (uriVariables == null) {
      throw ValidationException(
        'The Form href $href contains URI variables '
        'but no values were provided as InteractionOptions.',
      );
    }

    // Perform additional validation
    _validateUriVariables(
      hrefUriVariables,
      affordanceUriVariables,
      uriVariables,
    );

    // As "{" and "}" are "percent encoded" due to Uri.parse(), we need to
    // revert the encoding first before we can insert the values.
    final decodedHref = Uri.decodeFull(href.toString());

    // Everything should be okay at this point, we can simply insert the values
    // and return the result.
    final newHref = Uri.parse(UriTemplate(decodedHref).expand(uriVariables));
    return _copy(newHref);
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
    return 'UriVariableException: $message';
  }
}
