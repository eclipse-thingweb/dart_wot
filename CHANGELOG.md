# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.28.1] - 2024-05-17

### Changed

- Switched to the automated publishing workflow on pub.dev ([#118](https://github.com/eclipse-thingweb/dart_wot/pull/118))
- Switched to the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format for new changelog entries ([#115](https://github.com/eclipse-thingweb/dart_wot/pull/115))
- Adjusted the main example to also use HTTP and CoAP observe ([#101](https://github.com/eclipse-thingweb/dart_wot/pull/101))
- Adjusted the link to the initial release in the changelog ([#119](https://github.com/eclipse-thingweb/dart_wot/pull/119))

## [0.28.0] - 2024-04-28

### Added

- feat: implement requestThingDescription method ([#76](https://github.com/eclipse-thingweb/dart_wot/pull/76))
- feat: implement exploreDirectory method ([#84](https://github.com/eclipse-thingweb/dart_wot/pull/84))
- ci: add `codecov.yml` file ([#87](https://github.com/eclipse-thingweb/dart_wot/pull/87))
- Add missing copyright headers ([#92](https://github.com/eclipse-thingweb/dart_wot/pull/92))
- feat!: add initial support for query parameters to exploreDirectory method ([#94](https://github.com/eclipse-thingweb/dart_wot/pull/94))
- feat!: add supportsOperation method ([#96](https://github.com/eclipse-thingweb/dart_wot/pull/96))
- feat(binding_coap): add tryParse method to CoapSubprotocol ([#98](https://github.com/eclipse-thingweb/dart_wot/pull/98))
- docs: add new dart_wot logo to README ([#102](https://github.com/eclipse-thingweb/dart_wot/pull/102))

### Changed

- chore!: upgrade dependencies ([#56](https://github.com/eclipse-thingweb/dart_wot/pull/56))
- Improve `Content` APIs ([#57](https://github.com/eclipse-thingweb/dart_wot/pull/57))
- chore: remove `dart_code_metrics` dev dependency ([#58](https://github.com/eclipse-thingweb/dart_wot/pull/58))
- chore(deps): update dependencies ([#59](https://github.com/eclipse-thingweb/dart_wot/pull/59))
- docs: update node-wot link w.r.t. new project structure ([#63](https://github.com/eclipse-thingweb/dart_wot/pull/63))
- chore: update author in copyright headers ([#68](https://github.com/eclipse-thingweb/dart_wot/pull/68))
- chore: update URLs in README badges ([#70](https://github.com/eclipse-thingweb/dart_wot/pull/70))
- chore(pubspec.yaml): update homepage URL ([#69](https://github.com/eclipse-thingweb/dart_wot/pull/69))
- style: apply trailing comma linting suggestions ([#73](https://github.com/eclipse-thingweb/dart_wot/pull/73))
- chore: update dependencies ([#74](https://github.com/eclipse-thingweb/dart_wot/pull/74))
- chore: use correct license header for CoAP test files ([#79](https://github.com/eclipse-thingweb/dart_wot/pull/79))
- chore: convert third-party code note into an acknowledgment section ([#78](https://github.com/eclipse-thingweb/dart_wot/pull/78))
- feat!: simplify credentials callback usage ([#80](https://github.com/eclipse-thingweb/dart_wot/pull/80))
- feat: update TD 1.1 JSON Schema to final version ([#81](https://github.com/eclipse-thingweb/dart_wot/pull/81))
- feat(servient): improve handling of client factories ([#83](https://github.com/eclipse-thingweb/dart_wot/pull/83))
- feat!: simplify `InteractionOptions` ([#85](https://github.com/eclipse-thingweb/dart_wot/pull/85))
- feat: improve DataSchemaValue handling ([#86](https://github.com/eclipse-thingweb/dart_wot/pull/86))
- style: prefer double quotes over single quotes for Strings ([#90](https://github.com/eclipse-thingweb/dart_wot/pull/90))
- feat!: improve TD data model and serialization behavior ([#89](https://github.com/eclipse-thingweb/dart_wot/pull/89))
- feat!: make credentials classes immutable ([#93](https://github.com/eclipse-thingweb/dart_wot/pull/93))
- feat!: rework package structure ([#88](https://github.com/eclipse-thingweb/dart_wot/pull/88))
- chore: rename tests and file for CoAP definitions ([#97](https://github.com/eclipse-thingweb/dart_wot/pull/97))
- refactor(thing_discovery): refactor _clientForUriScheme ([#100](https://github.com/eclipse-thingweb/dart_wot/pull/100))
- refactor: improve performance of CoRE resource discovery ([#103](https://github.com/eclipse-thingweb/dart_wot/pull/103))
- refactor: introduce extension for CoRE Link-Format attribute values ([#105](https://github.com/eclipse-thingweb/dart_wot/pull/105))
- fix(servient): use WoT interface as start() return type ([#108](https://github.com/eclipse-thingweb/dart_wot/pull/108))
- fix(servient): check the correct map during addConsumedThing ([#109](https://github.com/eclipse-thingweb/dart_wot/pull/109))
- feat!: simplify custom exceptions ([#107](https://github.com/eclipse-thingweb/dart_wot/pull/107))
- refactor(InteractionOutput): use DataSchemaValue internally ([#110](https://github.com/eclipse-thingweb/dart_wot/pull/110))
- feat!: improve InteractionOutput implementation ([#106](https://github.com/eclipse-thingweb/dart_wot/pull/106))
- feat!: make custom exceptions immutable ([#111](https://github.com/eclipse-thingweb/dart_wot/pull/111))

### Removed

- chore: remove obsolete .gitlab directory ([#64](https://github.com/eclipse-thingweb/dart_wot/pull/64))
- ci: remove token from codecov upload step ([#72](https://github.com/eclipse-thingweb/dart_wot/pull/72))
- chore: delete .gitlab-ci.yml ([#75](https://github.com/eclipse-thingweb/dart_wot/pull/75))
- chore!(servient): remove `hasClientFor` method ([#99](https://github.com/eclipse-thingweb/dart_wot/pull/99))
- refactor: remove obsolete _FlatStreamExtension ([#104](https://github.com/eclipse-thingweb/dart_wot/pull/104))

### Fixed

- fix: fix duplicate URI detection during MDNS discovery ([#62](https://github.com/eclipse-thingweb/dart_wot/pull/62))
- fix: typo in file name ([#77](https://github.com/eclipse-thingweb/dart_wot/pull/77))
- fix: fix handling of URI variables ([#82](https://github.com/eclipse-thingweb/dart_wot/pull/82))
- fix: remove temporary TD context URI ([#91](https://github.com/eclipse-thingweb/dart_wot/pull/91))
- fix: fix handling of uri variables ([#95](https://github.com/eclipse-thingweb/dart_wot/pull/95))
- fix: typo ([#112](https://github.com/eclipse-thingweb/dart_wot/pull/112))

## [0.27.1] - 2023-05-14

### Changed

- chore: fix CHANGELOG formatting

## [0.27.0] - 2023-05-14

### Changed

- feat!: migrate library to Dart 3

## [0.26.0] - 2023-05-14

### Added

- feat: add ComboSecurityScheme

### Changed

- feat: update JSON Schema definition to latest version
- style: use const constructor in complex_example
- feat(scripting_api): make InteractionOptions immutable
- refactor!: rework deserialization of security schemes
- feat!(security_scheme): use Uri instead of String for proxy field
- refactor: decouple credentials and security scheme classes

### Fixed

- chore: address linting issues


## [0.25.1] - 2023-05-13

### Fixed

- fix: mark package as compatible with Dart 3.x.x

## [0.25.0] - 2023-05-13

### Changed

- feat(binding-coap)!: use blockSize instead of blockSZX

### Fixed

- fix(binding-coap): fix ACE behavior on Unauthorized Response

## [0.24.1] - 2023-03-04

### Fixed

- fix(discovery): extract port from DNS SRV records

## [0.24.0] - 2023-01-29

### Added

- feat: implement new CoAP vocabulary terms

### Changed

- chore: move node-wot license to a separate file

### Fixed

- chore(form): address linting issue
- style: fix formatting of mocked classes

## [0.23.1] - 2023-01-16

### Changed

- chore: update dependencies

## [0.23.0] - 2022-10-19

### Fixed

- fix: improved multicast discovery with CoRE Link-Format

## [0.22.1] - 2023-09-26

### Fixed

- fix(definitions): added missing `writeallproperties` operation

## [0.22.0] - 2023-09-26

### Changed

Applied an extensive rework to the `DataSchema` class, added missing TD fields,
and improved the support for additional fields and `@context` extensions via
JSON-LD.

## [0.21.1] - 2023-09-22

### Fixed

- fix: correctly parse String @context entries

## [0.21.0] - 2023-09-22

### Added

- feat: add Codec for CoRE Link Format
- feat: add missing contentCoding field to form
- feat(binding-coap): add ACE-OAuth support
- feat: add first version of MQTT binding
- feat: add support for CoRE RD discovery
- feat: add missing data schema fields

### Changed

- feat: adjust CoAP binding to new library API
- feat: improve ThingDescriptionValidationException
- feat!: allow passing invalid credentials to security callbacks
- Various refactorings, updated README file.

### Fixed

- fix(coap_client): correctly set URI path for discovery
- fix(coap_client): set accept to application/link-format for CoRE Link Format discovery
- fix(binding-coap): improve reponse error handling


## [0.20.1] - 2022-07-26

### Changed

- Refactored Direct CoAP Discovery internally and updated example

### Fixed

- Fixed a bug that occurred when an affordance output contains zero bytes
- Fixed a bug that prevented the correct setting of a CoAP Discovery URL
- Set the correct Content-Format for CoAP Discovery with CoRE Link Format

## [0.20.0] - 2022-06-23

### Added

- feat: add data model for AutoSecurityScheme
- feat: add example for basic and auto security

### Changed

- refactor: refactor HttpRequestMethod as enhanced enum
- feat(binding-http): rework security implementation, add security bootstrapping
  for discovery

## [0.19.2] - 2022-06-23

### Fixed

- fix: temporarily set `coap` version to 4.1.0

## [0.19.1] - 2022-06-23

### Fixed

- fix: prevent CoRE Web Links from being fetched twice

## [0.19.0] - 2022-06-12

### Changed

- Breaking: Set direct as default Discovery method
- Made linting config even stricter

## [0.18.0] - 2022-06-12

### Added

- Added support for parsing of a number of missing TD fields

### Changed

- Replaced a number of Errors with Exceptions to make library more stable
- Made various refactorings, applying a stricter linting config

## [0.17.0] - 2022-06-12

### Added

- Added JSON Schema Validation for TDs
- Added support for basic CoRE Resource Discovery

## [0.16.0] - 2022-05-30

### Changed

- Reworked credentials system (now uses a callback-based approach)
- Reworked the API for direct discovery via CoAP and HTTP
- Performed various refactorings

### Fixed

- fixed subscription implementation for CoAP

## [0.15.1] - 2022-05-22

### Added

- Added the new CoAP Binding-Template vocabulary to `complex_example.dart`

## [0.15.0] - 2022-05-21

### Added

- Added CURIE expansion for additional TD fields
- Added support for new CoAP Binding-Template
- Added experimental CoAPS support

## [0.14.0] - 2022-03-27

### Fixed

- Fixed constructor of `ThingFilter` class and aligned it with Scripting API

## [0.13.0] - 2022-03-27

### Added

- Added internal clean up methods

### Changed

- Refactored internal use of credentials
- Various smaller refactorings
- Improved test framework

### Fixed

- Fixed exposed ConsumedThing interface

## [0.12.1] - 2022-03-21

### Changed

- Updated examples

## [0.12.0] - 2022-03-21

### Added

- Added support for global URI Template variables
- Added JSON Schema validation to the Content Serializer/Deserializer

## [0.11.1] - 2022-03-14

### Changed

- Updated example in README.md

## [0.11.0] - 2022-03-14

### Added

- Added support for URI template variables

### Changed

- Updated dependencies (`cbor` and `coap`)

### Fixed

- Addressed linting issues

## [0.10.0] - 2022-03-11

### Added

- HTTP-Binding: Added support for Digest and Bearer Security

### Changed

- Improved Documentation

## [0.9.0] - 2022-02-23

### Changed

- Refactored ConsumedThing class
- Reworked subscribeResource API
- Set default contentType of Forms to application/json

### Fixed

- Fixed OAuth2 SecurityScheme and its documentation

## [0.8.0] - 2022-02-10

### Changed

- feat(discovery)!: re-align discovery API with current Scripting API specification

## [0.7.1] - 2022-02-03

### Added

- feat: add missing OAuth2Credentials class

## [0.7.0] - 2022-02-03

### Added

- feat: let TD parse links field
- feat: add support for basic Credentials to HTTP Client

### Changed

- docs: improve documentation
- feat!: rework API for Credentials, parse all SecuritySchemes

## [0.6.1] - 2022-01-20

### Changed

- feat: parse titles and descriptions at Thing level

## [0.6.0] - 2022-01-19

### Changed

- Package republished under 3-Clause BSD license

## [0.5.0] - 2022-01-18

### Added

- feat: parse affordance title(s) and description(s) of interaction affordances
- feat!: let Client Factories support multiple schemes
- feat(core)!: add subscription op types
- feat(core): implement subscription interfaces
- feat(scripting_api): add findUnsubscribeForm helper
- feat(definitions): add DataSchema fields to Event class
- feat(binding_coap): implement subscription API
- feat: implement readmultipleproperties, readallproperties, and writemultipleproperties operations
- feat: add property observation to example file
- feat!: implement basic Discovery API version

### Changed

- feat(scripting_api)!: clean up Subscription interface
- feat(binding_http): adjust according to subscription API
- feat(scripting_api): turn ThingFilter into concrete class
- feat: update example with Discovery features

### Removed

- feat(protocol_client)!: remove unneeded unsubscribeResource method

### Fixed

- fix: properly parse `op` field in Forms, improve Form augmentation
- fix: replace generic with concrete Exceptions
- docs(core): fix doc comment of client factory

## [0.4.0] - 2022-01-09

### Added

- Added first version of a basic HTTP binding (only client support yet)

### Changed

- Refactored and cleaned up CoAP package

## [0.3.0] - 2022-01-04

### Changed

- docs(helpers): better document fetch function
- refactor(binding-coap): do not export client
- refactor(core): move ContentSerdes to Servient

### Removed

- chore(binding_coap): remove unneeded import
- fix(helpers): remove unneeded fetch parameter
- refactor(helpers): remove unused import

### Fixed

- chore: fix format of LICENSE file

## [0.2.0] - 2022-01-01

### Changed

- docs: use a shorter README title
- refactor: clean up definition exports
- docs: improve documentation of libraries

## [0.1.1] - 2021-12-31

### Changed

- docs: expand package description

## [0.1.0] - 2021-12-31

## Added

- Initial version.

[0.28.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.28.0...v0.28.1
[0.28.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.27.1...v0.28.0
[0.27.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.27.0...v0.27.1
[0.27.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.26.0...v0.27.0
[0.26.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.25.1...v0.26.0
[0.25.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.25.0...v0.25.1
[0.25.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.24.1...v0.25.0
[0.24.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.24.0...v0.24.1
[0.24.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.23.1...v0.24.0
[0.23.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.23.0...v0.23.1
[0.23.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.22.1...v0.23.0
[0.22.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.22.0...v0.22.1
[0.22.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.21.1...v0.22.0
[0.21.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.21.0...v0.21.1
[0.21.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.20.1...v0.21.0
[0.20.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.20.0...v0.20.1
[0.20.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.19.2...v0.20.0
[0.19.2]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.19.1...v0.19.2
[0.19.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.19.0...v0.19.1
[0.19.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.18.0...v0.19.0
[0.18.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.17.0...v0.18.0
[0.17.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.16.0...v0.17.0
[0.16.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.15.1...v0.16.0
[0.15.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.15.0...v0.15.1
[0.15.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.14.0...v0.15.0
[0.14.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.13.0...v0.14.0
[0.13.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.12.1...v0.13.0
[0.12.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.12.0...v0.12.1
[0.12.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.11.1...v0.12.0
[0.11.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.11.0...v0.11.1
[0.11.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.10.0...v0.11.0
[0.10.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.9.0...v0.10.0
[0.9.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.8.0...v0.9.0
[0.8.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.7.1...v0.8.0
[0.7.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.6.1...v0.7.0
[0.6.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/eclipse-thingweb/dart_wot/releases/tag/v0.1.0

