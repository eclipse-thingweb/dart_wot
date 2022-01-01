[![Build](https://github.com/namib-project/dart_wot/actions/workflows/ci.yml/badge.svg)](https://github.com/namib-project/dart_wot/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/namib-project/dart_wot/branch/main/graph/badge.svg?token=76OBNOVL60)](https://codecov.io/gh/namib-project/dart_wot)

# dart_wot

dart_wot is an implementation of the
Web of Things [Scripting API](https://w3c.github.io/wot-scripting-api/) modelled
after the  WoT reference implementation
[node-wot](https://github.com/eclipse/thingweb.node-wot).
At the moment, it supports interacting with Things using the Constrained Application
Protocol (CoAP).

## Features

You can fetch and consume Thing Descriptions, and read and write properties as well as
invoking actions offered by a Thing.
Other protocols (such as HTTP(S)) as well as exposing, and discovering Things are not
yet supported but will be added in future versions.

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
import 'dart:async';
import 'dart:io';

import 'package:dart_wot/dart_wot.dart';

FutureOr<void> main(List<String> args) async {
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
            "href": "/.well-known/core"
          }
        ]
      }
    }
  }
  ''';

  final thingDescription = ThingDescription(thingDescriptionJson);
  final consumedThing = await wot.consume(thingDescription);
  final status = await consumedThing.readProperty("status", null);
  final value = await status.value();
  print(value);
  exit(0);
}
```

A more complex example can be found in the `example` directory.

## Additional information

The package will be extended gradually over the upcoming months.
Support for exposing and discovering Things will be added as well as
more protocols (especially HTTP and HTTPS, but also CoAPS).

Contributions are very welcome.
You will soon be able to find guidelines for contributing to the package
in a `CONTRIBUTING` file.
Until then you can already file issues for pointing out bugs or requesting
features.
You can also open PRs; these have to adhere the defined coding style and
linter rules.
Contributions will licensed according to the project licenses (see below).

## License

Licensed under either of
* MIT license
  ([LICENSE-MIT](LICENSE) or http://opensource.org/licenses/MIT)
* Apache License, Version 2.0
  ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
at your option.

## Note on Third-Party Code

This software includes material copied from
Eclipse Thingweb node-wot (https://github.com/eclipse/thingweb.node-wot).
Copyright (c) 2018 Contributors to the Eclipse Foundation

## Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall be
dual licensed as above, without any additional terms or conditions.

## Maintainers

This project is currently maintained by the following developers:

|    Name    |     Email Address    |                GitHub Username               |
|:----------:|:--------------------:|:--------------------------------------------:|
| Jan Romann | jan.romann@uni-bremen.de | [JKRhb](https://github.com/JKRhb) |
