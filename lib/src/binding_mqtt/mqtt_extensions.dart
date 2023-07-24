// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:curie/curie.dart";
import "package:mqtt_client/mqtt_client.dart";
import "package:mqtt_client/mqtt_server_client.dart";
import "package:uuid/uuid.dart";

import '../../core.dart';
import '../definitions/form.dart';
import '../definitions/security/auto_security_scheme.dart';
import '../definitions/security/basic_security_scheme.dart';
import '../definitions/validation/validation_exception.dart';
import 'constants.dart';

/// [PrefixMapping] for expanding MQTT Vocabulary terms from compact IRIs.
final mqttPrefixMapping = PrefixMapping(defaultPrefixValue: mqttContextUri);

/// Additional methods for making MQTT [Uri]s easier to work with.
extension MqttUriExtension on Uri {
  // TODO: Is this the right approach to creating an identifier here?
  String get _id => const Uuid().v4();

  /// Create an [MqttServerClient] from this [Uri].
  MqttServerClient createClient(int keepAlivePeriod) {
    final client = MqttServerClient.withPort(
      _brokerAddress,
      _id,
      _mqttPort,
    );

    if (scheme == mqttSecureUriScheme) {
      client.secure = true;
    }

    client
      ..setProtocolV311()
      ..keepAlivePeriod = keepAlivePeriod;
    return client;
  }

  String get _brokerAddress => host;

  int get _mqttPort {
    if (port == 0) {
      return _defaultPort;
    }

    return port;
  }

  int get _defaultPort {
    switch (scheme) {
      case mqttUriScheme:
        return defaultMqttPort;
      case mqttSecureUriScheme:
        return defaultMqttSecurePort;
    }

    throw StateError("MQTT URI scheme $scheme is not supported.");
  }
}

/// Additional methods for making MQTT [Form]s easier to work with.
extension MqttFormExtension on AugmentedForm {
  /// Indicates if this [Form] requires basic authentication.
  bool requiresBasicAuthentication(BasicCredentials? credentials) {
    if (_hasBasicSecurityScheme) {
      return true;
    }

    return _hasAutoSecurityScheme && credentials == null;
  }

  T? _obtainVocabularyTerm<T>(String term) {
    final curieString = mqttPrefixMapping.expandCurie(Curie(reference: term));

    final value = additionalFields[curieString] ??
        additionalFields["$defaultMqttPrefix:$term"];

    if (value is T) {
      return value;
    }

    return null;
  }

  /// Gets the MQTT topic for publishing from this [Form].
  ///
  /// If present, this getter uses the dedicated vocabulary term `topic`.
  /// Otherwise, the URI path from the `href` field is being used as a fallback.
  String get topicName {
    final topic = _obtainVocabularyTerm<String>("topic");

    if (topic != null) {
      return topic;
    }

    final path = Uri.decodeComponent(href.path);

    if (path.isEmpty) {
      return path;
    }

    return path.substring(1);
  }

  /// Gets the MQTT topic for subscribing from this [Form].
  ///
  /// If present, this getter uses the dedicated vocabulary term `filter`.
  /// Otherwise, the URI query from the `href` field is being used as a
  /// fallback.
  String get topicFilter {
    final topic = _obtainVocabularyTerm<String>("filter");

    if (topic != null) {
      return topic;
    }

    return Uri.decodeComponent(href.query.replaceAll("&", "/"));
  }

  /// Gets the MQTT `retain` value from this [Form] if present.
  ///
  /// Returns `null` otherwise.
  bool? get retain => _obtainVocabularyTerm<bool>("retain");

  bool get _hasBasicSecurityScheme =>
      securityDefinitions.whereType<BasicSecurityScheme>().isNotEmpty;

  bool get _hasAutoSecurityScheme =>
      securityDefinitions.whereType<AutoSecurityScheme>().isNotEmpty;

  /// Gets the MQTT Quality of Service from this [Form] if present.
  ///
  /// Returns `null` otherwise.
  MqttQos? get qualityOfService {
    final qosValue = _obtainVocabularyTerm<String>("qos");
    switch (qosValue) {
      case "quality:0":
        return MqttQos.atMostOnce;
      case "quality:1":
        return MqttQos.atLeastOnce;
      case "quality:2":
        return MqttQos.exactlyOnce;
    }

    // TODO: This validation should maybe already happen earlier.
    if (qosValue != null) {
      throw FormatException(
        "Encountered unknown QoS value $qosValue. "
        "in form with href $href of Thing Description with Identifier "
        "$tdIdentifier.",
      );
    }

    return null;
  }
}

/// Extensions for the [MqttServerClient] class.
extension MqttClientExtension on MqttServerClient {
  /// Connect using optional [credentials].
  Future<MqttClientConnectionStatus?> connectWithCredentials(
    BasicCredentials? credentials,
  ) async =>
      connect(
        credentials?.username,
        credentials?.password,
      );
}
