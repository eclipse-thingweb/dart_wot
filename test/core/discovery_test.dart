// Copyright 2023 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "dart:async";
import "dart:convert";

import "package:dart_wot/core.dart";
import "package:test/test.dart";

const testUriScheme = "test";
final validTestDiscoveryUri =
    Uri.parse("$testUriScheme://[::1]/.well-known/wot");
final invalidTestDiscoveryUri =
    Uri.parse("$testUriScheme://[::2]/.well-known/wot");
final directoryTestUri1 = Uri.parse("$testUriScheme://[::3]/.well-known/wot");
final directoryTestThingsUri1 = Uri.parse("$testUriScheme://[::3]/things");
final directoryTestUri2 = Uri.parse("$testUriScheme://[::4]/.well-known/wot");
final directoryTestThingsUri2 = Uri.parse("$testUriScheme://[::4]/things");
final directoryTestUri3 = Uri.parse("$testUriScheme://[::5]/.well-known/wot");
final directoryTestThingsUri3 = Uri.parse("$testUriScheme://[::5]/things");
final directoryTestUri4 = Uri.parse("$testUriScheme://[::6]/.well-known/wot");
final directoryTestThingsUri4 = Uri.parse(
  "$testUriScheme://[::3]/things?offset=2&limit=3&format=array",
);

const validTestTitle1 = "Test TD 1";
const validTestThingDescription = '''
  {
      "@context": "https://www.w3.org/2022/wot/td/v1.1",
      "title": "$validTestTitle1",
      "security": "nosec_sc",
      "securityDefinitions": {
        "nosec_sc": {"scheme": "nosec"}
      }
  }
''';

const validDirectoryTestTitle1 = "Test TD 2";
final directoryThingDescription1 = '''
{
  "@context": [
    "https://www.w3.org/2022/wot/td/v1.1",
    "https://www.w3.org/2022/wot/discovery"
  ],
  "@type": "ThingDirectory",
  "title": "$validDirectoryTestTitle1",
  "security": "nosec_sc",
  "securityDefinitions": {
    "nosec_sc": {"scheme": "nosec"}
  },
  "properties": {
    "things": {
      "uriVariables": {
        "offset": {
          "title": "Number of TDs to skip before the page",
          "type": "number",
          "default": 0
        },
        "limit": {
          "title": "Number of TDs in a page",
          "type": "number"
        },
        "format": {
          "title": "Payload format",
          "type": "string",
          "enum": [
            "array",
            "collection"
          ],
          "default": "array"
        }
      },
      "forms": [
        {
          "href": "$directoryTestThingsUri1"
        }
      ]
    }
  }
}
''';

const validDirectoryTestTitle2 = "Test TD 3";
final directoryThingDescription2 = '''
{
  "@context": [
    "https://www.w3.org/2022/wot/td/v1.1",
    "https://www.w3.org/2022/wot/discovery"
  ],
  "@type": "ThingDirectory",
  "title": "$validDirectoryTestTitle2",
  "security": "nosec_sc",
  "securityDefinitions": {
    "nosec_sc": {"scheme": "nosec"}
  },
  "properties": {
    "things": {
      "forms": [
        {
          "href": "$directoryTestThingsUri2"
        }
      ]
    }
  }
}
''';

const validDirectoryTestTitle3 = "Test TD 2";
final directoryThingDescription3 = '''
{
  "@context": [
    "https://www.w3.org/2022/wot/td/v1.1",
    "https://www.w3.org/2022/wot/discovery"
  ],
  "@type": "ThingDirectory",
  "title": "$validDirectoryTestTitle3",
  "security": "nosec_sc",
  "securityDefinitions": {
    "nosec_sc": {"scheme": "nosec"}
  },
  "properties": {
    "things": {
      "forms": [
        {
          "href": "$directoryTestThingsUri3"
        }
      ]
    }
  }
}
''';

const invalidTestThingDescription1 = '"Hi there!"';
const invalidTestThingDescription2 = '''
  {"foo": "bar"}
''';

final class _MockedProtocolClient extends ProtocolClient with DirectDiscoverer {
  @override
  Future<Content> invokeResource(Form form, Content content) {
    // TODO: implement invokeResource
    throw UnimplementedError();
  }

  @override
  Future<Content> readResource(AugmentedForm form) async {
    final href = form.resolvedHref;

    if (href == directoryTestThingsUri1) {
      return "[$validTestThingDescription]".toContent("application/td+json");
    }

    if (href == directoryTestThingsUri2) {
      return "[$invalidTestThingDescription2]".toContent("application/td+json");
    }

    if (href == directoryTestThingsUri3) {
      return invalidTestThingDescription2.toContent("application/td+json");
    }

    if (href == directoryTestThingsUri4) {
      return "[$validTestThingDescription]".toContent("application/ld+json");
    }

    throw StateError("Encountered an unknown URI $href.");
  }

  @override
  Future<Content> discoverDirectly(Uri url) async {
    if (url == validTestDiscoveryUri) {
      return validTestThingDescription.toDiscoveryContent(url);
    }

    if (url == invalidTestDiscoveryUri) {
      return invalidTestThingDescription1.toDiscoveryContent(url);
    }

    if (url == directoryTestUri1) {
      return directoryThingDescription1.toDiscoveryContent(url);
    }

    if (url == directoryTestUri2) {
      return directoryThingDescription2.toDiscoveryContent(url);
    }

    if (url == directoryTestUri3) {
      return directoryThingDescription3.toDiscoveryContent(url);
    }

    if (url == directoryTestUri4) {
      return directoryThingDescription1.toDiscoveryContent(url);
    }

    throw StateError("Encountered invalid URL.");
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

  @override
  bool supportsOperation(OperationType operationType, String? subprotocol) =>
      true;
}

extension _DiscoveryContentCreationExtension on String {
  Stream<List<int>> get _body => Stream.fromIterable([utf8.encode(this)]);

  DiscoveryContent toDiscoveryContent(Uri url) {
    return DiscoveryContent("application/td+json", _body, url);
  }

  Content toContent(String type) {
    return Content(type, _body);
  }
}

void main() {
  group("requestThingDescription()", () {
    test("should be able to retrieve a valid TD", () async {
      final servient = Servient.create(
        clientFactories: [
          _MockedProtocolClientFactory(),
        ],
      );

      final wot = await servient.start();
      final thingDescription =
          await wot.requestThingDescription(validTestDiscoveryUri);

      expect(thingDescription.title, validTestTitle1);
    });

    test(
      "should throw an exception when an invalid TD is retrieved",
      () async {
        final servient = Servient.create(
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

  group("exploreDirectory()", () {
    test("should be able to discover valid TDs from a TD directory", () async {
      final servient = Servient.create(
        clientFactories: [
          _MockedProtocolClientFactory(),
        ],
      );

      final wot = await servient.start();
      final thingDiscoveryProcess =
          await wot.exploreDirectory(directoryTestUri1);

      var counter = 0;
      await for (final thingDescription in thingDiscoveryProcess) {
        counter++;
        expect(thingDescription.title, validTestTitle1);
      }
      expect(counter, 1);
      expect(thingDiscoveryProcess.done, true);
    });

    test("should reject invalid TDD Thing Descriptions", () async {
      final servient = Servient.create(
        clientFactories: [
          _MockedProtocolClientFactory(),
        ],
      );

      final wot = await servient.start();

      expect(
        () async => await wot.exploreDirectory(validTestDiscoveryUri),
        throwsA(isA<DiscoveryException>()),
      );
    });

    test("should be able to handle an array of invalid TDs during discovery",
        () async {
      final servient = Servient.create(
        clientFactories: [
          _MockedProtocolClientFactory(),
        ],
      );

      final wot = await servient.start();
      final thingDiscoveryProcess =
          await wot.exploreDirectory(directoryTestUri2);

      var counter = 0;

      final testCompleter = Completer<void>();

      thingDiscoveryProcess.listen(
        (event) {
          counter++;
        },
        onError: (error, stackTrace) async {},
        onDone: () {
          expect(counter, 0);
          expect(thingDiscoveryProcess.done, true);
          expect(thingDiscoveryProcess.error, isNotNull);
          testCompleter.complete();
        },
      );

      return testCompleter.future;
    });

    test(
        "should be able to handle an invalid non-array output during discovery",
        () async {
      final servient = Servient.create(
        clientFactories: [
          _MockedProtocolClientFactory(),
        ],
      );

      final wot = await servient.start();

      expect(
        () async => wot.exploreDirectory(directoryTestUri3),
        throwsA(isException),
      );
    });

    test("should be able to handle premature cancellation", () async {
      final servient = Servient.create(
        clientFactories: [
          _MockedProtocolClientFactory(),
        ],
      );

      final wot = await servient.start();
      final thingDiscoveryProcess =
          await wot.exploreDirectory(directoryTestUri1);

      await thingDiscoveryProcess.stop();
      expect(thingDiscoveryProcess.done, true);

      // Cancelling twice should not change the state
      await thingDiscoveryProcess.stop();
      expect(thingDiscoveryProcess.done, true);
    });

    test("should support the experimental query parameters API", () async {
      final servient = Servient.create(
        clientFactories: [
          _MockedProtocolClientFactory(),
        ],
      );

      final wot = await servient.start();
      final thingDiscoveryProcess = await wot.exploreDirectory(
        directoryTestUri4,
        offset: 2,
        limit: 3,
        format: DirectoryPayloadFormat.array,
      );

      var counter = 0;
      await for (final thingDescription in thingDiscoveryProcess) {
        counter++;
        expect(thingDescription.title, validTestTitle1);
      }
      expect(counter, 1);
      expect(thingDiscoveryProcess.done, true);
    });

    test(
        'should currently not support the "collection" format when using the '
        "experimental query parameters API", () async {
      final servient = Servient.create();
      final wot = await servient.start();

      expect(
        () async => await wot.exploreDirectory(
          directoryTestUri4,
          format: DirectoryPayloadFormat.collection,
        ),
        throwsArgumentError,
      );
    });
  });
}
