// Copyright 2022 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:async";

import "package:mqtt_client/mqtt_client.dart" hide Subscription;
import "package:mqtt_client/mqtt_server_client.dart";
import "package:typed_data/typed_buffers.dart";

import "../../core.dart";

import "constants.dart";
import "mqtt_binding_exception.dart";
import "mqtt_config.dart";
import "mqtt_extensions.dart";
import "mqtt_subscription.dart";

/// [ProtocolClient] for supporting the MQTT protocol.
///
/// Currently, only MQTT version 3.1.1 is supported.
final class MqttClient extends ProtocolClient with MqttDiscoverer {
  /// Constructor.
  MqttClient({
    MqttConfig? mqttConfig,
    AsyncClientSecurityCallback<BasicCredentials>? basicCredentialsCallback,
  })  : _mqttConfig = mqttConfig ?? MqttConfig(),
        _basicCredentialsCallback = basicCredentialsCallback;

  final AsyncClientSecurityCallback<BasicCredentials>?
      _basicCredentialsCallback;

  final MqttConfig _mqttConfig;

  Future<BasicCredentials?> _obtainCredentials(
    Uri uri,
    AugmentedForm? form, [
    BasicCredentials? invalidCredentials,
    bool unauthorized = false,
  ]) async {
    final requiresBasicAuthentication =
        form?.requiresBasicAuthentication(invalidCredentials) ?? false;
    final isDiscovery = form == null && unauthorized;

    if (!(requiresBasicAuthentication || isDiscovery)) {
      return null;
    }

    final basicCredentials =
        _basicCredentialsCallback?.call(uri, form, invalidCredentials);

    if (basicCredentials != null) {
      return basicCredentials;
    }

    if (form != null) {
      throw MqttBindingException(
        "Form requires basic authentication but no credentials were provided.",
      );
    }

    throw MqttBindingException(
      "Discovery requires basic authentication but no credentials were "
      "provided.",
    );
  }

  Future<MqttServerClient> _connectWithForm(AugmentedForm form) async =>
      _connect(form.resolvedHref, form);

  Future<MqttServerClient> _connect(Uri brokerUri, AugmentedForm? form) async {
    final client = brokerUri.createClient(_mqttConfig.keepAlivePeriod);
    final credentials = await _obtainCredentials(brokerUri, form);

    MqttClientConnectionStatus? status;

    try {
      status = await client.connectWithCredentials(credentials);
    } on NoConnectionException {
      // Ask user for (new) credentials
      final newCredentials =
          await _obtainCredentials(brokerUri, form, credentials);
      if (newCredentials != null) {
        status = await client.connectWithCredentials(newCredentials);
      }
    }

    if (status?.state != MqttConnectionState.connected) {
      throw MqttBindingException("Connecting failed");
    }

    return client;
  }

  @override
  Future<Content> invokeResource(AugmentedForm form, Content content) async {
    final client = await _connectWithForm(form);
    final topic = form.topicName;
    final qualityOfService =
        form.qualityOfService ?? _mqttConfig.defaultActionQoS.mqttQoS;

    client
      ..publishMessage(
        topic,
        qualityOfService,
        Uint8Buffer()..addAll(await content.toByteList()),
        retain: form.retain ?? false,
      )
      ..disconnect();

    return Content(defaultContentType, const Stream<List<int>>.empty());
  }

  @override
  Future<Content> readResource(AugmentedForm form) async {
    final client = await _connectWithForm(form);
    final topic = form.topicFilter;
    final qualityOfService =
        form.qualityOfService ?? _mqttConfig.defaultReadQoS.mqttQoS;

    final completer = Completer<Content>();

    final timer = Timer(
      _mqttConfig.readTimeout,
      () => completer.completeError(
        TimeoutException("Reading resource $topic failed"),
      ),
    );

    // TODO: Revisit QoS value and subscription check
    if (client.subscribe(topic, qualityOfService) == null) {
      throw MqttBindingException("Subscription to topic $topic failed");
    }

    client.updates?.listen((messages) {
      for (final message in messages) {
        final publishedMessage = message.payload as MqttPublishMessage;
        final payload = publishedMessage.payload.message;

        completer.complete(Content(form.contentType, Stream.value(payload)));
        timer.cancel();
        break;
      }
    });

    final content = await completer.future;
    client.disconnect();

    return content;
  }

  @override
  Future<void> writeResource(AugmentedForm form, Content content) async {
    final client = await _connectWithForm(form);
    final topic = form.topicName;
    final qualityOfService =
        form.qualityOfService ?? _mqttConfig.defaultWriteQoS.mqttQoS;

    client
      ..publishMessage(
        topic,
        qualityOfService,
        Uint8Buffer()..addAll(await content.toByteList()),
        retain: form.retain ?? false,
      )
      ..disconnect();
  }

  @override
  Future<void> start() async {
    // Do nothing
  }

  @override
  Future<void> stop() async {
    // Do nothing
  }

  @override
  Future<Subscription> subscribeResource(
    AugmentedForm form, {
    required void Function(Content content) next,
    required void Function() complete,
    void Function(Exception error)? error,
  }) async {
    final client = await _connectWithForm(form);
    final topic = form.topicFilter;
    final qualityOfService =
        form.qualityOfService ?? _mqttConfig.defaultSubscribeQoS.mqttQoS;

    // TODO: Revisit QoS value and subscription check
    if (client.subscribe(topic, qualityOfService) == null) {
      throw MqttBindingException("Subscription to topic $topic failed");
    }

    return MqttSubscription(form, client, complete, next: next, error: error);
  }

  @override
  Stream<Content> performMqttDiscovery(
    Uri brokerUri, {
    required String discoveryTopic,
    required String expectedContentType,
    required Duration discoveryTimeout,
  }) async* {
    final client = await _connect(brokerUri, null);

    // TODO: Revisit QoS value and subscription check
    if (client.subscribe(discoveryTopic, MqttQos.atLeastOnce) == null) {
      throw MqttBindingException(
        "Subscription to topic $discoveryTopic failed",
      );
    }

    final receivedMessageStream = client.updates;
    if (receivedMessageStream == null) {
      throw MqttBindingException(
        "Subscription to topic $discoveryTopic failed",
      );
    }

    Timer(
      discoveryTimeout,
      () async {
        client.disconnect();
      },
    );

    await for (final receivedMessageList in receivedMessageStream) {
      for (final receivedMessage in receivedMessageList) {
        final mqttMessage = receivedMessage.payload;
        if (mqttMessage is MqttPublishMessage) {
          final messagePayload = mqttMessage.payload.message;

          yield Content(expectedContentType, Stream.value(messagePayload));
        }
      }
    }
  }
}
