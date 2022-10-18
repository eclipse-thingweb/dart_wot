import 'dart:io';
import 'dart:typed_data';

import 'package:cbor/cbor.dart';
import 'package:coap/coap.dart';
import 'package:dcaf/dcaf.dart';

import '../core/content.dart';
import '../definitions/form.dart';
import '../definitions/operation_type.dart';
import '../definitions/security/ace_security_scheme.dart';
import '../definitions/security/auto_security_scheme.dart';
import '../definitions/security/psk_security_scheme.dart';
import 'coap_binding_exception.dart';
import 'coap_definitions.dart';

const _validBlockwiseValues = [16, 32, 64, 128, 256, 512, 1024];

/// Extension which makes it easier to handle [Uri]s containing
/// [InternetAddress]es.
extension InternetAddressMethods on Uri {
  /// Checks whether the host of this [Uri] is a multicast [InternetAddress].
  bool get isMulticastAddress {
    return InternetAddress.tryParse(host)?.isMulticast ?? false;
  }
}

/// CoAP-specific extensions for the [Form] class.
extension CoapFormExtension on Form {
  /// Determines if this [Form] supports the [PskSecurityScheme].
  bool get usesPskScheme =>
      securityDefinitions.whereType<PskSecurityScheme>().isNotEmpty;

  /// Determines if this [Form] supports the [AutoSecurityScheme].
  bool get usesAutoScheme =>
      securityDefinitions.whereType<AutoSecurityScheme>().isNotEmpty;

  /// Get the [CoapSubprotocol] for this [Form], if one is set.
  CoapSubprotocol? get coapSubprotocol {
    if (subprotocol == coapPrefixMapping.expandCurieString('observe')) {
      return CoapSubprotocol.observe;
    }

    return null;
  }

  CoapMediaType _determineContentFormat(String contentType, String? encoding) {
    return CoapMediaType.parse(contentType, encoding) ??
        CoapMediaType.applicationJson;
  }

  /// The Content-Format for CoAP request and response payloads.
  CoapMediaType get format {
    return _determineContentFormat(contentType, contentCoding);
  }

  /// The Content-Format for the Accept option CoAP request and response
  /// payloads.
  CoapMediaType get accept {
    // TODO: The algorithm for accept needs to be adjusted
    return _determineContentFormat(contentType, contentCoding);
  }

  int? _determineBlockSize(String fieldName) {
    const blockwiseVocabularyName = 'blockwise';
    final curieString =
        coapPrefixMapping.expandCurieString(blockwiseVocabularyName);
    final dynamic formDefinition = additionalFields[curieString];

    if (formDefinition is! Map<String, dynamic>) {
      return null;
    }

    final blockwiseParameterName =
        coapPrefixMapping.expandCurieString(fieldName);
    final dynamic value = formDefinition[blockwiseParameterName];

    if (value is int && !_validBlockwiseValues.contains(value)) {
      return value;
    }

    return null;
  }

  /// Indicates the Block2 size preferred by a server.
  int? get block2Size => _determineBlockSize('block2SZX');

  /// Indicates the Block1 size preferred by a server.
  int? get block1Size => _determineBlockSize('block1SZX');

  /// Gets a list of all defined [AceSecurityScheme]s for this form.
  List<AceSecurityScheme> get aceSecuritySchemes =>
      securityDefinitions.whereType<AceSecurityScheme>().toList();
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
      OperationType.unobserveproperty
    ].contains(this)) {
      return CoapSubprotocol.observe;
    }

    return null;
  }
}

/// Extension for easily extracting the [content] from a [CoapResponse].
extension ResponseExtension on CoapResponse {
  Stream<List<int>> get _payloadStream {
    final payload = this.payload;
    if (payload != null) {
      return Stream.value(payload);
    } else {
      return const Stream.empty();
    }
  }

  String get _contentType =>
      contentFormat?.contentType.toString() ?? 'application/json';

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
      CoapCode.unauthorized,
      CoapCode.methodNotAllowed,
      CoapCode.forbidden,
    ];

    final responsePayload = payload;

    if (responsePayload != null &&
        contentFormat == CoapMediaType.applicationAceCbor &&
        unauthorizedAceCodes.contains(contentFormat)) {
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
        'ACE-OAuth Profile $aceProfile is not supported.',
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
        'Proof of Possession Key for establishing a DTLS connection must be '
        'symmetric',
      );
    }
    final key = cnf.key.parameters[-1];
    final Uint8List preSharedKey;
    if (key is CborBytes) {
      preSharedKey = Uint8List.fromList(key.bytes);
    } else {
      throw CoapBindingException(
        'Proof of Possession Key for establishing a DTLS connection must be '
        'bytes',
      );
    }

    return PskCredentials(identity: identity, preSharedKey: preSharedKey);
  }
}
