// Copyright 2023 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:convert';

import 'package:dart_wot/dart_wot.dart';
import 'package:dart_wot/src/core/content.dart';
import 'package:dart_wot/src/core/thing_discovery.dart';
import 'package:test/test.dart';

const testUriScheme = 'test';
final validTestDiscoveryUri =
    Uri.parse('$testUriScheme://[::1]/.well-known/wot');
final invalidTestDiscoveryUri =
    Uri.parse('$testUriScheme://[::2]/.well-known/wot');

const validTestTitle = 'Test TD';
const validTestThingDescription = '''
  {
      "@context": "https://www.w3.org/2022/wot/td/v1.1",
      "title": "$validTestTitle",
      "security": "nosec_sc",
      "securityDefinitions": {
        "nosec_sc": {"scheme": "nosec"}
      }
  }
''';

const invalidTestThingDescription = '"Hi there!"';

void main() {
  group('Discovery Tests', () {
    test('Should be able to use the requestThingDescription method', () async {
      final servient = Servient(
        clientFactories: [
          _MockedProtocolClientFactory(),
        ],
      );

      final wot = await servient.start();
      final thingDescription =
          await wot.requestThingDescription(validTestDiscoveryUri);

      expect(thingDescription.title, validTestTitle);
    });

    test(
      'Should throw an exception if an invalid TD results from the '
      'requestThingDescription method',
      () async {
        final servient = Servient(
          clientFactories: [
            _MockedProtocolClientFactory(),
          ],
        );

        final wot = await servient.start();
        await expectLater(
          wot.requestThingDescription(invalidTestDiscoveryUri),
          // TODO: Refine error handling
          throwsA(isA<DiscoveryException>()),
        );
      },
    );
  });
}

class _MockedProtocolClient implements ProtocolClient {
  @override
  Stream<DiscoveryContent> discoverWithCoreLinkFormat(Uri uri) {
    // TODO: implement discoverWithCoreLinkFormat
    throw UnimplementedError();
  }

  @override
  Future<Content> invokeResource(Form form, Content content) {
    // TODO: implement invokeResource
    throw UnimplementedError();
  }

  @override
  Future<Content> readResource(Form form) {
    // TODO: implement readResource
    throw UnimplementedError();
  }

  @override
  Future<Content> requestThingDescription(Uri url) async {
    if (url == validTestDiscoveryUri) {
      return validTestThingDescription.toDiscoveryContent(url);
    }

    if (url == invalidTestDiscoveryUri) {
      return invalidTestThingDescription.toDiscoveryContent(url);
    }

    throw StateError('Encountered invalid URL.');
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
    Form form, {
    required void Function(Content content) next,
    void Function(Exception error)? error,
    required void Function() complete,
  }) {
    // TODO: implement subscribeResource
    throw UnimplementedError();
  }

  @override
  Future<void> writeResource(Form form, Content content) {
    // TODO: implement writeResource
    throw UnimplementedError();
  }

  @override
  Stream<DiscoveryContent> discoverDirectly(
    Uri uri, {
    bool disableMulticast = false,
  }) {
    // TODO: implement discoverDirectly
    throw UnimplementedError();
  }
}

class _MockedProtocolClientFactory implements ProtocolClientFactory {
  @override
  ProtocolClient createClient() {
    return _MockedProtocolClient();
  }

  @override
  bool destroy() {
    return true;
  }

  @override
  bool init() {
    return true;
  }

  @override
  Set<String> get schemes => {testUriScheme};
}

extension _DiscoveryContentCreationExtension on String {
  DiscoveryContent toDiscoveryContent(Uri url) {
    final body = Stream.fromIterable([utf8.encode(this)]);
    return DiscoveryContent('application/td+json', body, url);
  }
}
