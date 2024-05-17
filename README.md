[![pub package](https://img.shields.io/pub/v/dart_wot.svg)](https://pub.dev/packages/dart_wot)
[![Build](https://github.com/eclipse-thingweb/dart_wot/actions/workflows/ci.yml/badge.svg)](https://github.com/eclipse-thingweb/dart_wot/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/eclipse-thingweb/dart_wot/branch/main/graph/badge.svg?token=76OBNOVL60)](https://codecov.io/gh/eclipse-thingweb/dart_wot)
[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/eclipse-thingweb/thingweb/main/brand/logos/dart_wot_for_dark_bg.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/eclipse-thingweb/thingweb/main/brand/logos/dart_wot.svg">
  <img title="Thingweb dart_wot " alt="Thingweb dart_wot logo" src="https://raw.githubusercontent.com/eclipse-thingweb/thingweb/main/brand/logos/dart_wot.svg" width="300">
</picture>

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

Below you can find a basic example for incrementing and reading the value of a
counter Thing, which is part of the
[Thingweb Online Things](https://www.thingweb.io/services).

In the example, we first create a WoT runtime using a `Servient` with CoAP and
HTTP support.
With the runtime, we then retrieve a TD (using the `requestThingDescription()`
method) and consume it (using the `consume()` method), creating a
`ConsumedThing` object,
Afterward, the actual interactions with the counter are performed by calling the
`invokeAction()` and `readProperty()` methods on the `ConsumedThing`.

```dart
import "package:dart_wot/binding_coap.dart";
import "package:dart_wot/binding_http.dart";
import "package:dart_wot/core.dart";

Future<void> main(List<String> args) async {
  final servient = Servient(
    clientFactories: [
      CoapClientFactory(),
      HttpClientFactory(),
    ],
  );
  final wot = await servient.start();

  final url = Uri.parse("coap://plugfest.thingweb.io/counter");
  print("Requesting TD from $url ...");
  final thingDescription = await wot.requestThingDescription(url);

  final consumedThing = await wot.consume(thingDescription);
  print(
    "Successfully retrieved and consumed TD with title "
    '"${thingDescription.title}"!',
  );

  print(consumedThing.thingDescription.events);
  final subscription = await consumedThing.subscribeEvent("change", print);

  print("Incrementing counter ...");
  await consumedThing.invokeAction("increment");

  final status = await consumedThing.readProperty("count");
  final value = await status.value();
  print("New counter value: $value");

  await subscription.stop();
}
```

More complex examples can be found in the `example` directory.

## License

`dart_wot` is licensed under the 3-Clause BSD License.
See the `LICENSE` file for more information.

    SPDX-License-Identifier: BSD-3-Clause

## Acknowledgements

`dart_wot` was inspired by Eclipse Thingweb
[node-wot](https://github.com/eclipse/thingweb.node-wot), a W3C Web of Things
implementation for the Node.js ecosystem.

## Contribution

Please refer to our [contribution guidelines](CONTRIBUTING.md) for more details.

## Maintainers

This project is currently maintained by the following developers:

|    Name    |     Email Address    |                GitHub Username               |
|:----------:|:--------------------:|:--------------------------------------------:|
| Jan Romann | jan.romann@uni-bremen.de | [JKRhb](https://github.com/JKRhb) |
