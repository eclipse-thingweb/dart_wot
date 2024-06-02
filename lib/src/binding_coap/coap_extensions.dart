// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:typed_data";

import "package:cbor/cbor.dart";
import "package:coap/coap.dart";
import "package:dcaf/dcaf.dart";

import "../../core.dart" hide PskCredentials;

import "coap_binding_exception.dart";
import "coap_definitions.dart";

/// CoAP-specific extensions for the [AugmentedForm] class.
extension CoapFormExtension on AugmentedForm {
  T? _obtainVocabularyTerm<T>(String vocabularyTerm) {
    final curieString = coapPrefixMapping.expandCurieString(vocabularyTerm);
    final formDefinition = additionalFields[curieString];

    if (formDefinition is T) {
      return formDefinition;
    }

    return null;
  }

  /// Determines if this [AugmentedForm] supports the [PskSecurityScheme].
  bool get usesPskScheme =>
      securityDefinitions.whereType<PskSecurityScheme>().isNotEmpty;

  /// Determines if this [AugmentedForm] supports the [AutoSecurityScheme].
  bool get usesAutoScheme =>
      securityDefinitions.whereType<AutoSecurityScheme>().isNotEmpty;

  /// Get the [CoapSubprotocol] for this [AugmentedForm], if one is set.
  CoapSubprotocol? get coapSubprotocol {
    if (subprotocol == coapPrefixMapping.expandCurieString("observe")) {
      return CoapSubprotocol.observe;
    }

    return null;
  }

  /// The Content-Format for CoAP request and response payloads.
  CoapMediaType get contentFormat {
    final formDefinition = _obtainVocabularyTerm<int>("contentFormat");
    final contentFormat = CoapMediaType.fromIntValue(formDefinition ?? -1);

    return contentFormat ??
        CoapMediaType.parse(contentType, contentCoding) ??
        CoapMediaType.applicationJson;
  }

  /// The Content-Format for the Accept option CoAP request and response
  /// payloads.
  CoapMediaType? get accept {
    final formDefinition = _obtainVocabularyTerm<int>("accept");
    return CoapMediaType.fromIntValue(formDefinition ?? -1);
  }

  BlockSize? _determineBlockSize(String fieldName) {
    final blockwiseParameters =
        _obtainVocabularyTerm<Map<String, dynamic>>("blockwise");

    if (blockwiseParameters == null) {
      return null;
    }

    final blockwiseParameterName =
        coapPrefixMapping.expandCurieString(fieldName);
    final dynamic value = blockwiseParameters[blockwiseParameterName];

    if (value is! int) {
      return null;
    }

    // FIXME: Should not throw an ArgumentError
    try {
      return BlockSize.fromDecodedValue(value);
      // ignore: avoid_catching_errors
    } on ArgumentError {
      throw FormatException(
        "Encountered invalid blocksize $value in CoAP form",
      );
    }
  }

  /// Indicates the Block2 size preferred by a server.
  BlockSize? get block2Size => _determineBlockSize("block2Size");

  /// Indicates the Block1 size preferred by a server.
  BlockSize? get block1Size => _determineBlockSize("block1Size");

  // TODO: Consider default method
  /// Indicates the [CoapRequestMethod] contained in this [AugmentedForm].
  CoapRequestMethod? get method {
    final methodDefinition = _obtainVocabularyTerm<String>("method");

    if (methodDefinition == null) {
      return null;
    }

    return CoapRequestMethod.fromString(methodDefinition);
  }

  /// Gets a list of all defined [AceSecurityScheme]s for this form.
  List<AceSecurityScheme> get aceSecuritySchemes =>
      securityDefinitions.whereType<AceSecurityScheme>().toList();
}

/// CoAP-specific extensions for the [ExpectedResponse] class.
extension CoapExpectedResponseExtension on ExpectedResponse {
  T? _obtainVocabularyTerm<T>(String vocabularyTerm) {
    final curieString = coapPrefixMapping.expandCurieString(vocabularyTerm);
    final formDefinition = additionalFields?[curieString];

    if (formDefinition is T) {
      return formDefinition;
    }

    return null;
  }

  /// The Content-Format for CoAP request and response payloads.
  CoapMediaType get contentFormat {
    final formDefinition = _obtainVocabularyTerm<int>("contentFormat");
    final contentFormat = CoapMediaType.fromIntValue(formDefinition ?? -1);

    return contentFormat ??
        CoapMediaType.parse(contentType) ??
        CoapMediaType.applicationJson;
  }
}

/// Extension for determining the corresponding [CoapRequestMethod] and
/// [CoapSubprotocol] for an [OperationType].
extension OperationTypeExtension on OperationType {
  /// Determines the [CoapRequestMethod] for this [OperationType].
  CoapRequestMethod get requestMethod {
    switch (this) {
      case OperationType.readproperty:
      case OperationType.readmultipleproperties:
      case OperationType.readallproperties:
        return CoapRequestMethod.get;
      case OperationType.writeproperty:
      case OperationType.writemultipleproperties:
      case OperationType.writeallproperties:
        return CoapRequestMethod.put;
      case OperationType.invokeaction:
        return CoapRequestMethod.post;
      case OperationType.observeproperty:
      case OperationType.unobserveproperty:
        return CoapRequestMethod.get;
      case OperationType.subscribeevent:
      case OperationType.unsubscribeevent:
        return CoapRequestMethod.get;
    }
  }

  /// Determines the [CoapSubprotocol] (if any) for this [OperationType].
  ///
  /// The only supported subprotocol at the moment is `observe`.
  CoapSubprotocol? get subprotocol {
    if ([
      OperationType.subscribeevent,
      OperationType.unsubscribeevent,
      OperationType.observeproperty,
      OperationType.unobserveproperty,
    ].contains(this)) {
      return CoapSubprotocol.observe;
    }

    return null;
  }
}

/// Extension for easily extracting the [content] from a [CoapResponse].
extension ResponseExtension on CoapResponse {
  Stream<List<int>> get _payloadStream => Stream.value(payload);

  String get _contentType =>
      contentFormat?.contentType.toString() ?? "application/json";

  /// Extract the [Content] of this [CoapResponse].
  Content get content {
    return Content(_contentType, _payloadStream);
  }

  /// Extract the [Content] of this [CoapResponse].
  DiscoveryContent determineDiscoveryContent(String scheme) {
    // ignore: invalid_use_of_internal_member
    final discoveryUri = Uri(scheme: scheme, host: source?.host);
    return DiscoveryContent(_contentType, _payloadStream, discoveryUri);
  }

  /// Checks the [code] of this [CoapResponse] and throws an [Exception] if it
  /// should indicate an error.
  void checkResponseCode() {
    if (code.isServerError) {
      throw CoapServerErrorException(this);
    }

    if (code.isErrorResponse) {
      throw CoapClientErrorException(this);
    }
  }

  /// Validates the payload and returns a serialized ACE creation hint if
  /// successful.
  AuthServerRequestCreationHint? get creationHint {
    const unauthorizedAceCodes = [
      // TODO: Should other response codes be included as well?
      ResponseCode.unauthorized,
      ResponseCode.methodNotAllowed,
      ResponseCode.forbidden,
    ];

    final responsePayload = payload;

    if (contentFormat == CoapMediaType.applicationAceCbor &&
        unauthorizedAceCodes.contains(responseCode)) {
      return AuthServerRequestCreationHint.fromSerialized(
        responsePayload.toList(),
      );
    }
    return null;
  }
}

/// Extension for conveniently retrieving [PskCredentials] from an
/// [AccessTokenResponse].
extension PskExtension on AccessTokenResponse {
  void _checkAceProfile() {
    final aceProfile = this.aceProfile;
    if (aceProfile != null && aceProfile != AceProfile.coapDtls) {
      throw CoapBindingException(
        "ACE-OAuth Profile $aceProfile is not supported.",
      );
    }
  }

  /// Obtains [PskCredentials] for DTLS from this [AccessTokenResponse].
  ///
  /// Throws a [CoapBindingException] if the deserialization should fail or the
  /// wrong format has been provided.
  PskCredentials get pskCredentials {
    _checkAceProfile();
    final identity = Uint8List.fromList(accessToken);
    final cnf = this.cnf;
    if (cnf is! PlainCoseKey) {
      throw CoapBindingException(
        "Proof of Possession Key for establishing a DTLS connection must be "
        "symmetric",
      );
    }
    final key = cnf.key.parameters[-1];
    final Uint8List preSharedKey;
    if (key is CborBytes) {
      preSharedKey = Uint8List.fromList(key.bytes);
    } else {
      throw CoapBindingException(
        "Proof of Possession Key for establishing a DTLS connection must be "
        "bytes",
      );
    }

    return PskCredentials(identity: identity, preSharedKey: preSharedKey);
  }
}
