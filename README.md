[![pub package](https://img.shields.io/pub/v/dart_wot.svg)](https://pub.dev/packages/dart_wot)
[![Build](https://github.com/eclipse-thingweb/dart_wot/actions/workflows/ci.yml/badge.svg)](https://github.com/eclipse-thingweb/dart_wot/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/eclipse-thingweb/dart_wot/branch/main/graph/badge.svg?token=76OBNOVL60)](https://codecov.io/gh/eclipse-thingweb/dart_wot)
[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)

# dart_wot

dart_wot is an implementation of the
Web of Things [Scripting API](https://w3c.github.io/wot-scripting-api/) modelled
after the WoT reference implementation
[node-wot](https://github.com/eclipse-thingweb/node-wot).
At the moment, it supports interacting with Things using the Constrained Application
Protocol (CoAP), the Hypertext Transfer Protocol (HTTP), and the MQTT protocol.

## Features

You can consume Thing Descriptions and interact with a Thing based on its
exposed Properties, Actions, and Events.
Discovery support is currently limited to the "direct" method (i.e. fetching a
TD using a single URL).
Exposing Things is not yet supported but will be added in future versions.

Using the Protocol Interfaces in the `core` package, you can add support for
additional protocols in your own application or library. The main requirement
for this to work is the existence of a URI scheme for the given protocol.

## Getting started

To get started, you first need to install the package by adding it to your
`pubspec.yaml` file.
You can use `dart pub add dart_wot` (for a Dart project) or
`flutter pub add dart_wot` (for a Flutter project) to do so.

You can then use the package in your project by adding
`import 'package:dart_wot/dart_wot.dart'` to your source files.

## Usage

Below you can find a very basic example for reading a status from a Thing (using the
`coap.me` test server).
To do so, a Thing Description JSON string is first parsed and turned into a
`ThingDescription` object, which is then passed to a WoT runtime created by a
`Servient` with CoAP support.

```dart
import 'package:dart_wot/dart_wot.dart';

Future<void> main(List<String> args) async {
  final CoapClientFactory coapClientFactory = CoapClientFactory(null);
  final servient = Servient()..addClientFactory(coapClientFactory);
  final wot = await servient.start();

  final thingDescriptionJson = '''
  {
    "@context": "http://www.w3.org/ns/td",
    "title": "Test Thing",
    "base": "coap://coap.me",
    "security": ["nosec_sc"],
    "securityDefinitions": {
      "nosec_sc": {
        "scheme": "nosec"
      }
    },
    "properties": {
      "status": {
        "forms": [
          {
            "href": "/hello"
          }
        ]
      }
    }
  }
  ''';

  final thingDescription = ThingDescription(thingDescriptionJson);
  final consumedThing = await wot.consume(thingDescription);
  final status = await consumedThing.readProperty("status");
  final value = await status.value();
  print(value);
}
```

A more complex example can be found in the `example` directory.

## Additional information

The package will be extended gradually over the upcoming months.
Support for exposing Things will be added as well as
more protocols and security schemes.

Contributions are very welcome.
You will soon be able to find guidelines for contributing to the package
in a `CONTRIBUTING` file.
Until then, you can already file issues for pointing out bugs or requesting
features.
You can also open PRs; these have to adhere the defined coding style and
linter rules.
Contributions will be licensed according to the project licenses (see below).

## License

`dart_wot` is licensed under the 3-Clause BSD License.
See the `LICENSE` file for more information.

    SPDX-License-Identifier: BSD-3-Clause

## Note on Third-Party Code

This software includes material copied from
Eclipse Thingweb node-wot (https://github.com/eclipse/thingweb.node-wot).
Copyright © 2018 Contributors to the Eclipse Foundation.
See the `LICENSE-THIRD-PARTY` file for more information.

## Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, shall be licensed as above, without any additional
terms or conditions.

## Maintainers

This project is currently maintained by the following developers:

|    Name    |     Email Address    |                GitHub Username               |
|:----------:|:--------------------:|:--------------------------------------------:|
| Jan Romann | jan.romann@uni-bremen.de | [JKRhb](https://github.com/JKRhb) |
