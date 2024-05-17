# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Add cliff.toml config for git-cliff ([fc98f23](https://github.com/eclipse-thingweb/dart_wot/commit/fc98f239ea08db872805c0db071d5d0cf4f3c08a))

## [0.28.2] - 2024-05-17

### Changed

- Switch to automated publishing workflow ([be744a6](https://github.com/eclipse-thingweb/dart_wot/commit/be744a69eb3b56d5cda1831b452da659dc3319e4))
- Update CHANGELOG ([8094c8c](https://github.com/eclipse-thingweb/dart_wot/commit/8094c8cf1501f0fff6b9ad0fa4935db75e673905))

## [0.28.1] - 2024-05-17

### Added

- Add HTTP support to main example ([9c27e65](https://github.com/eclipse-thingweb/dart_wot/commit/9c27e6519c7541612a5889936be6adcdbf96317f))
- Add event subscribing to the main example ([e4ededb](https://github.com/eclipse-thingweb/dart_wot/commit/e4ededb18f112acfa088924ccc4510b311c43c6a))

### Changed

- Switch to the keep a changelog format ([7a1c10a](https://github.com/eclipse-thingweb/dart_wot/commit/7a1c10a29146b7b1e3d6a764f720c616eb5cd766))
- Add changes since last release ([396fbf2](https://github.com/eclipse-thingweb/dart_wot/commit/396fbf2582d1d0fe97fcf93df180f92590e80331))
- Update old changelog entries ([cba0fd1](https://github.com/eclipse-thingweb/dart_wot/commit/cba0fd117fcce03c0743f0e3fce24ec7d6aa18df))
- Use Dart 3.3.0 for Windows ([2030591](https://github.com/eclipse-thingweb/dart_wot/commit/2030591fc96183c5e2f52f8c9f9ab2ffcb105cb3))
- Use correct link to initial release ([b1e9b82](https://github.com/eclipse-thingweb/dart_wot/commit/b1e9b822bece534b9cc92acde9780e16406727be))
- Update CHANGELOG ([c48ee7c](https://github.com/eclipse-thingweb/dart_wot/commit/c48ee7c24cc081a3b22143e5ae3ed498461cb115))

## [0.28.0] - 2024-04-28

### Added

- Add toByteList method to Content class ([1eba374](https://github.com/eclipse-thingweb/dart_wot/commit/1eba374847e7546c7abcd0a344de9ccb738d3733))
- Add optional clientFactories contructor parameter ([6099cbb](https://github.com/eclipse-thingweb/dart_wot/commit/6099cbbc06ad3c257732e297c434a04381e95c60))
- Add `removeClientFactory` method ([4489819](https://github.com/eclipse-thingweb/dart_wot/commit/44898194873483bff3c6b515f5bdb978f8937faf))
- Add tests for handling ProtocolClientFactories ([568bb89](https://github.com/eclipse-thingweb/dart_wot/commit/568bb89496e0ffd66ee549b11f1efff082df1e81))
- Add tests for requestThingDescription method ([e5b5745](https://github.com/eclipse-thingweb/dart_wot/commit/e5b57454d90d77fb5dcc5d263e8d35d5ffd779d4))
- Add tests for `exploreDirectory` method ([215bec3](https://github.com/eclipse-thingweb/dart_wot/commit/215bec35cdbb41463052897464b41c4c55a77f41))
- Add missing parsing of @type at the TD level ([e921b65](https://github.com/eclipse-thingweb/dart_wot/commit/e921b65505d0ac9d5d9783afdf0e9422bb2a76c8))
- Add tests for reworked InteractionInput class ([e172533](https://github.com/eclipse-thingweb/dart_wot/commit/e172533bbffce7987ff6b73a0628ed607ff1d767))
- Add tests for codecs ([1065e5b](https://github.com/eclipse-thingweb/dart_wot/commit/1065e5b146dbddc42f65b69bea4ebfbe590086ca))
- Add tests for DataSchemaValue ([1bb198b](https://github.com/eclipse-thingweb/dart_wot/commit/1bb198b8d63bc9f5134edde3e807995d82a53b1b))
- Add tests for InteractionOutput class ([5c495b4](https://github.com/eclipse-thingweb/dart_wot/commit/5c495b44497f54e2da2290ccec0423a4723352e6))
- Add tests for Content class ([2feb002](https://github.com/eclipse-thingweb/dart_wot/commit/2feb0022a0cf1c58ffbb0f360a4ccb6158887859))
- Add codecov.yml file ([960629e](https://github.com/eclipse-thingweb/dart_wot/commit/960629e6a34a9518f918da03826d0906871760c8))
- Add missing copyright header to coap_extensions file ([2896557](https://github.com/eclipse-thingweb/dart_wot/commit/2896557e40811702ded298cff3bece1997a2ece8))
- Add missing copyright header to http_request_method file ([4164509](https://github.com/eclipse-thingweb/dart_wot/commit/4164509ab90157c48178ab2fea1bfbf98f097f99))
- Add missing copyright header to json_parser file ([2ff4c9c](https://github.com/eclipse-thingweb/dart_wot/commit/2ff4c9c242c5626bfbb0261a38c19240081adf56))
- Add missing copyright header to version_info file ([2c238e3](https://github.com/eclipse-thingweb/dart_wot/commit/2c238e31356bba7c1e6a3e201a68ced3e0ae4222))
- Add initial support for query parameters to exploreDirectory method ([8f99cd8](https://github.com/eclipse-thingweb/dart_wot/commit/8f99cd86e3d97895cd337ddb98e3d1529600ba73))
- Add test for exploreDirectory query parameters ([df42311](https://github.com/eclipse-thingweb/dart_wot/commit/df4231185dfb2f59e932d3b7eed80837bc83342a))
- Add example for directory discovery ([17334a9](https://github.com/eclipse-thingweb/dart_wot/commit/17334a9f61b1797ff46315e9b71e17e552373804))
- Add tryParse method to CoapSubprotocol ([1fac84b](https://github.com/eclipse-thingweb/dart_wot/commit/1fac84bc4a34a05e49b04cbb5b8f65ecb3022d45))
- Add test for CoapSubprotocol.tryParse ([a4a7626](https://github.com/eclipse-thingweb/dart_wot/commit/a4a76267fddfb0c1039f96af5bf43a84ff5587ce))
- Add supportsOperation methods across codebase ([7d03e6c](https://github.com/eclipse-thingweb/dart_wot/commit/7d03e6c1b14bb3ff7260b96a21e5baba44fd98cf))
- Add missing cov:observe to complex_example ([2781723](https://github.com/eclipse-thingweb/dart_wot/commit/2781723c8c4cd6e878373c6374ddfdeaa5e7db00))
- Add tests for supportsOperation methods ([6f3ffa7](https://github.com/eclipse-thingweb/dart_wot/commit/6f3ffa7ea735b2a40fd85b7643dbd3674a049e8b))
- Add new dart_wot logo to README ([ed3257a](https://github.com/eclipse-thingweb/dart_wot/commit/ed3257a2615b55faebd0885e2f9665a1663f6dc8))
- Add additional tests for exceptions ([ab9e2ab](https://github.com/eclipse-thingweb/dart_wot/commit/ab9e2abf2b3464219d39aad0ec755a06da2980a2))
- Add additional tests ([a4af92b](https://github.com/eclipse-thingweb/dart_wot/commit/a4af92b635b4b29b0f650c8242f14e9978bf6642))
- Add CHANGELOG entry for version 0.28.0 ([d144a23](https://github.com/eclipse-thingweb/dart_wot/commit/d144a239d8ac99f9a7b94cdb22f91c3a2784aa40))

### Changed

- Replace json_schema3 with json_schema ([8dd87ea](https://github.com/eclipse-thingweb/dart_wot/commit/8dd87ea5bae2a84c22168276ed3af9c814fcd044))
- Upgrade coap dependency ([7296663](https://github.com/eclipse-thingweb/dart_wot/commit/729666398105a21fbf65ddfef93a6fd05ecde28d))
- Upgrade other dependencies ([0abb45f](https://github.com/eclipse-thingweb/dart_wot/commit/0abb45f1ee25f8eee46f74f9757701ec083cd9c2))
- Refactor byteBuffer getter ([0b89228](https://github.com/eclipse-thingweb/dart_wot/commit/0b89228d5ec3711b38cca7d08ded88d5c2e9935f))
- Use List<int> for ContentCodec API ([89b223d](https://github.com/eclipse-thingweb/dart_wot/commit/89b223d48a4505b0ec5e0d09a0c4f3c4803d1634))
- Simplify input data handling ([e9885f3](https://github.com/eclipse-thingweb/dart_wot/commit/e9885f307439741d35fcdbf1b5388a7e1b64f691))
- Update dependencies ([9fe1588](https://github.com/eclipse-thingweb/dart_wot/commit/9fe158811caf88d08fb80fed8dca780db5857082))
- Update node-wot link w.r.t. new project structure ([367ceca](https://github.com/eclipse-thingweb/dart_wot/commit/367ceca900ccf29a5038497ca7f84060e4b7a171))
- Update author in copyright headers ([acb318e](https://github.com/eclipse-thingweb/dart_wot/commit/acb318e39ced92d9c34118542b668bad8b2a0e8c))
- Update URLs in README badges ([53b40a0](https://github.com/eclipse-thingweb/dart_wot/commit/53b40a0b47456d61024cbcf5462720b6b62298e5))
- Update homepage URL ([887540a](https://github.com/eclipse-thingweb/dart_wot/commit/887540a7bb1a5d9ffc57a7c256d12f946efffd12))
- Apply trailing comma linting suggestions ([e1c5a2f](https://github.com/eclipse-thingweb/dart_wot/commit/e1c5a2f6ab7c755da35738b0295d281e4cc40cdf))
- Upgrade uuid to version 4.2.1 ([dfc5af1](https://github.com/eclipse-thingweb/dart_wot/commit/dfc5af1e517fdd97ba4e9ac92925cf71c3842395))
- Upgrade lints to version 3.0.0 ([7114992](https://github.com/eclipse-thingweb/dart_wot/commit/711499213f44c90beffd2b71bcca7be8ba4d8770))
- Use correct license header for CoAP test files ([1cf3176](https://github.com/eclipse-thingweb/dart_wot/commit/1cf3176ec2eb5fa86f9a15f757222b74b44adb64))
- Convert third-party code note into an acknowledgment section ([0ead1b8](https://github.com/eclipse-thingweb/dart_wot/commit/0ead1b88e0c04fc55baf29015439a8b845308d0b))
- Simplify credentials callback usage ([5caeedf](https://github.com/eclipse-thingweb/dart_wot/commit/5caeedf65d925179ddb28fae22e9a2b62cd98b2f))
- Update TD 1.1 JSON Schema to final version ([2fa98a6](https://github.com/eclipse-thingweb/dart_wot/commit/2fa98a6d76d60c2c02e582a9d2fce8f2ab191fa0))
- Improve constructor documentation ([0a040c9](https://github.com/eclipse-thingweb/dart_wot/commit/0a040c9e6373870080f7552083a2676956195529))
- Prefer clientFactories parameter to addClientFactory ([ee06909](https://github.com/eclipse-thingweb/dart_wot/commit/ee0690958b03743419f3cb7fd0ad51d170af2cce))
- Implement requestThingDescription method ([4e890e0](https://github.com/eclipse-thingweb/dart_wot/commit/4e890e03033ee451573f4afdd1d2752d7f8a0af8))
- Simplify main example ([83b256c](https://github.com/eclipse-thingweb/dart_wot/commit/83b256cc38c9991cdf4995bc15399e4fc6ebe2bc))
- Create seperate MQTT example ([86d18d3](https://github.com/eclipse-thingweb/dart_wot/commit/86d18d3cee39dc0245359aba673c8906f35639b3))
- Deprecate old `discover` method implementation ([086ad2c](https://github.com/eclipse-thingweb/dart_wot/commit/086ad2c4208e0c48eb9f677da1e999910bf9127a))
- Implement `exploreDirectory` method ([3a9ef63](https://github.com/eclipse-thingweb/dart_wot/commit/3a9ef63f918539df0bb4e48cfbfc1179281c5e4c))
- Simplify `InteractionOptions` ([d769629](https://github.com/eclipse-thingweb/dart_wot/commit/d769629e5ed71f11dff31e40725e09355ea7508a))
- Adjust names of InteractionInput parameters ([36f4be4](https://github.com/eclipse-thingweb/dart_wot/commit/36f4be4474cc18596bf5c9e72aa0cbf22056b381))
- Improve DataSchemaValue handling ([ef81993](https://github.com/eclipse-thingweb/dart_wot/commit/ef8199324c9dcc24209f9eb90e0518e31e253f48))
- Prefer double quotes over single quotes for Strings ([0d72bf2](https://github.com/eclipse-thingweb/dart_wot/commit/0d72bf21cab60191e01e0e1db988b8e1c55ec478))
- Improve TD serialization behavior ([88bbe14](https://github.com/eclipse-thingweb/dart_wot/commit/88bbe14c0a1e6727127d1c5205c5a74e54b55643))
- Introduce toThingDescription extension method ([270d1b9](https://github.com/eclipse-thingweb/dart_wot/commit/270d1b9936ccfbfcf22ef88db47a608a930b10ac))
- Make credentials classes immutable ([670d96a](https://github.com/eclipse-thingweb/dart_wot/commit/670d96a65f2d926f11ddbcc47fdbac120bd8eac8))
- Rework library structure ([05e628f](https://github.com/eclipse-thingweb/dart_wot/commit/05e628ff84daf6dc1d0ac333f856dd59f44bfb83))
- Rephrase CoAP definitions test names ([d333e70](https://github.com/eclipse-thingweb/dart_wot/commit/d333e70ebba879132ae7a90c017156607cb14bc1))
- Rename CoAP definitions test file ([fcd88d0](https://github.com/eclipse-thingweb/dart_wot/commit/fcd88d09e7e323917c84a0841b2f028e38e59a5b))
- Refactor _clientForUriScheme ([97a20ba](https://github.com/eclipse-thingweb/dart_wot/commit/97a20baa487e7ba68a4ca6da96861f5d4d39d3b1))
- Improve performance of CoRE resource discovery ([a234a99](https://github.com/eclipse-thingweb/dart_wot/commit/a234a9974a2de7b371ee2bcfb57e572da13a7c56))
- Introduce extension for CoRE Link-Format attribute values ([b30dcbd](https://github.com/eclipse-thingweb/dart_wot/commit/b30dcbdaa113348925cf720e3968a62d10726552))
- Simplify custom exceptions ([c9ea575](https://github.com/eclipse-thingweb/dart_wot/commit/c9ea575a1f78742e1b9dba097ac306f38661e174))
- Change phrasing of Servient test descriptions ([9878db5](https://github.com/eclipse-thingweb/dart_wot/commit/9878db549c5ffcc87cf6272909e861deb70c732d))
- Use DataSchemaValue internally ([c279d69](https://github.com/eclipse-thingweb/dart_wot/commit/c279d69bd8e6d0ae13bf3d555852e0a71d1a4ffc))
- Improve implementation documentation ([d6acedc](https://github.com/eclipse-thingweb/dart_wot/commit/d6acedcdde72feb4b6fed07fd0aa80e49b117146))
- Introduce NotReadableException ([c04303d](https://github.com/eclipse-thingweb/dart_wot/commit/c04303d24a292aa2f4db4ab0f2c443c886f6b56b))
- Improve interface documentation ([57a303b](https://github.com/eclipse-thingweb/dart_wot/commit/57a303b85501d22ff1f123b1ccf91f7d128319ff))
- Make custom exceptions immutable ([9030dd6](https://github.com/eclipse-thingweb/dart_wot/commit/9030dd691fd84fa9ccf51ec250bd1db897c51f93))

### Fixed

- Skip HTTP tests that use httpbin ([d0bf7ad](https://github.com/eclipse-thingweb/dart_wot/commit/d0bf7adf989af96a1f1e86357b984b51f3047db1))
- Fix duplicate URI detection during MDNS discovery ([08548b9](https://github.com/eclipse-thingweb/dart_wot/commit/08548b9f09bfe896a3e10e0d84c4e769fd755315))
- Typo in file name ([4c47c7a](https://github.com/eclipse-thingweb/dart_wot/commit/4c47c7a99f7b8a094d6555047950c907cd60cb05))
- Simplify handling of uriVariables ([d3d2919](https://github.com/eclipse-thingweb/dart_wot/commit/d3d2919a823843a1986686e5ac42321173ee3bfb))
- Don't use uriVariables for validating ([207b362](https://github.com/eclipse-thingweb/dart_wot/commit/207b3628fece310892373efec7f5561283eb0081))
- Fix `addClientFactory` documentation ([841703d](https://github.com/eclipse-thingweb/dart_wot/commit/841703d986b5bae0c08cf462e7811bf7a25ee445))
- Improve ContentSerdes tests ([7b2a9d8](https://github.com/eclipse-thingweb/dart_wot/commit/7b2a9d81fc874be5012f710094976992a124aa4a))
- Improve ConsumedThing tests ([4552ad6](https://github.com/eclipse-thingweb/dart_wot/commit/4552ad697612c2a4125f52bb88df31fdd1882251))
- Update examples ([273d57e](https://github.com/eclipse-thingweb/dart_wot/commit/273d57eeecc9b22741b1982ca3112e96f4a5e3fc))
- Fix handling of uri variables ([d265c4f](https://github.com/eclipse-thingweb/dart_wot/commit/d265c4f57c986e743fb8f3977096d24dc546410d))
- Use WoT interface as start() return type ([343aafe](https://github.com/eclipse-thingweb/dart_wot/commit/343aafe7361305499b1d4ce741d74ed69421e20a))
- Check the correct map during addConsumedThing ([c0e9a09](https://github.com/eclipse-thingweb/dart_wot/commit/c0e9a09d168710c42a39ef8e5c32981824ec8f58))
- Adjust implementation to spec ([115b0ff](https://github.com/eclipse-thingweb/dart_wot/commit/115b0ff716eb67bad1d119ce123057f6b62772e5))
- Typoe ([7cd9ba4](https://github.com/eclipse-thingweb/dart_wot/commit/7cd9ba4cec0005e2326dd3a504253e51f05e9ab8))

### Removed

- Remove dart_code_metrics ([b023d46](https://github.com/eclipse-thingweb/dart_wot/commit/b023d466294e99ca3d4a737314ec4420ed164d2c))
- Remove obsolete .gitlab directory ([a0648e2](https://github.com/eclipse-thingweb/dart_wot/commit/a0648e22cd748befe5266f13c6808b40caf9a2d2))
- Remove token from codecov upload step ([e43cb26](https://github.com/eclipse-thingweb/dart_wot/commit/e43cb26edcfdd2a74cc5d7a2622dbc852eec7d29))
- Delete .gitlab-ci.yml ([6fe447c](https://github.com/eclipse-thingweb/dart_wot/commit/6fe447c3b7f3b8fc221b70f697d74c683f5bb4ec))
- Remove obsolete explicit typing ([0facb78](https://github.com/eclipse-thingweb/dart_wot/commit/0facb783358293c46dfc4a8a0ad001c35b1d0e8c))
- Remove temporary TD context URI ([167f08f](https://github.com/eclipse-thingweb/dart_wot/commit/167f08fc488e0ab55dd99c8a2f1f7e449a6a70f3))
- Remove obsolete _FlatStreamExtension ([a635b1f](https://github.com/eclipse-thingweb/dart_wot/commit/a635b1f927e90a96f4c2549400117670fbf139ba))

## [0.27.1] - 2023-05-14

### Changed

- Bump version to 0.27.1 ([b10c3ba](https://github.com/eclipse-thingweb/dart_wot/commit/b10c3ba4fd3c7a06ddafd2916285b8cbb3fc8eca))

### Fixed

- Fix CHANGELOG formatting ([57dadbf](https://github.com/eclipse-thingweb/dart_wot/commit/57dadbf2a1a500e3616325e8bfe807841f079fd7))

## [0.27.0] - 2023-05-13

### Changed

- Increase minimal required Dart version to 3.0.0 ([dd5c8ff](https://github.com/eclipse-thingweb/dart_wot/commit/dd5c8ffc87844ca8c07cbdea5a2f895764c04485))
- Rework @context parsing using record type ([b6f95de](https://github.com/eclipse-thingweb/dart_wot/commit/b6f95dee31995304eb891b6a6b59455efa0a5eb7))
- Replace _ClientAndForm class with Record ([6df9d87](https://github.com/eclipse-thingweb/dart_wot/commit/6df9d87250e4a3faca340d97ee21ecd904a770c6))
- Use new class keywords for credentials ([e92aac8](https://github.com/eclipse-thingweb/dart_wot/commit/e92aac8388de6a740b584fb57b4c2ed35ad175c9))
- Use new class modifiers for SecurityScheme classes ([7ff9916](https://github.com/eclipse-thingweb/dart_wot/commit/7ff99161e521ba9f8d7b22dd2054d656da52ab3e))
- Use new class keywords for protocol interfaces ([5ef5148](https://github.com/eclipse-thingweb/dart_wot/commit/5ef5148ad52fd54c73cf8776e8714f0d6dded8ff))
- Use interface modifier for Scripting API definitions ([e9aca81](https://github.com/eclipse-thingweb/dart_wot/commit/e9aca814d79eab9dbb4ee5cbb195a818e0d18604))
- Bump version to 0.27.0 ([5970363](https://github.com/eclipse-thingweb/dart_wot/commit/5970363b85071da9d3b66d7dc4206c0ff690ad1a))

### Removed

- Remove obsolete break statements from switches ([98cd71d](https://github.com/eclipse-thingweb/dart_wot/commit/98cd71d794fbaeca2d812692fd00a3be2cae5247))

## [0.26.0] - 2023-05-13

### Added

- Add ComboSecurityScheme ([f0705d0](https://github.com/eclipse-thingweb/dart_wot/commit/f0705d0ddeb49d377244f3eb8cc864f8353b89e1))
- Add test cases for ComboSecurityScheme ([97637e0](https://github.com/eclipse-thingweb/dart_wot/commit/97637e003d4e3211c7fddefcdb508c311073804d))

### Changed

- Decouple credentials and security scheme classes ([b0b3768](https://github.com/eclipse-thingweb/dart_wot/commit/b0b376867fa86a2c997e7fd5a66039035f50ef23))
- Update actions/checkout to v3 ([9dce941](https://github.com/eclipse-thingweb/dart_wot/commit/9dce9413684d9e29d1c3f313f980034ce853b93a))
- Update codecov/codecov-action to v3 ([1501a07](https://github.com/eclipse-thingweb/dart_wot/commit/1501a07d50ba0246559d85635b2052e6c3aa8923))
- Improve documentation of proxy field ([0b9e5e9](https://github.com/eclipse-thingweb/dart_wot/commit/0b9e5e9cf7b846211d8f891a73197847c258837d))
- Rework deserialization of security schemes ([617e064](https://github.com/eclipse-thingweb/dart_wot/commit/617e064039b19a9470089431da6a43f8d4c2bf38))
- Make InteractionOptions immutable ([0dbae16](https://github.com/eclipse-thingweb/dart_wot/commit/0dbae16e82dc8e24be624256a144a1ce0860da90))
- Use const constructor in complex_example ([3f6c5c2](https://github.com/eclipse-thingweb/dart_wot/commit/3f6c5c2853146b515b34472ed050c256dc316f0c))
- Update JSON Schema definition to latest version ([2e5cdff](https://github.com/eclipse-thingweb/dart_wot/commit/2e5cdff36baee36be65c570a2a16c38d785ff170))
- Bump version to 0.26.0 ([c295ea7](https://github.com/eclipse-thingweb/dart_wot/commit/c295ea77d62e4f04c112fb737e87250988041fc4))

## [0.25.1] - 2023-05-13

### Changed

- Bump version to 0.25.1 ([0ac3185](https://github.com/eclipse-thingweb/dart_wot/commit/0ac31858a0aa42aaae39a63d6c9ad563802a6416))

### Fixed

- Mark package as compatible with Dart 3.x.x ([dc76b12](https://github.com/eclipse-thingweb/dart_wot/commit/dc76b12f7cb0f30a7ae79d1c485176632e243b2d))

## [0.25.0] - 2023-05-13

### Added

- Add missing library directives ([f386126](https://github.com/eclipse-thingweb/dart_wot/commit/f386126f315ef5da4b6c236d965792b4c4a7c77e))

### Changed

- Use blockSize instead of blockSZX ([4b76850](https://github.com/eclipse-thingweb/dart_wot/commit/4b768501aef1f2d0f61b94fd60a64cdd544e46cd))
- Bump version to 0.25.0 ([d7cba3a](https://github.com/eclipse-thingweb/dart_wot/commit/d7cba3a565384a35d33f0d743f7fa8f1678419d3))

### Fixed

- Fix ACE behavior on Unauthorized Response ([bb4b054](https://github.com/eclipse-thingweb/dart_wot/commit/bb4b054eb4e74fd5d0f4d1e3b75bd9a45787b4f9))

### Removed

- Remove unused code from DNS-SD example ([1086c7f](https://github.com/eclipse-thingweb/dart_wot/commit/1086c7fc5fa34cd9ce413177e7b6b87f78aeceb0))

## [0.24.1] - 2023-03-04

### Added

- Add DNS-SD CoAP example ([e548bb7](https://github.com/eclipse-thingweb/dart_wot/commit/e548bb71bbc0b5e0b19bc8c4bfba062e03a7f6aa))

### Changed

- Update `coap` dependency, fix example ([4928baa](https://github.com/eclipse-thingweb/dart_wot/commit/4928baa76c398a6bc8b91eecf179375cd2516f3a))
- Simplify code coverage generation ([cd5547b](https://github.com/eclipse-thingweb/dart_wot/commit/cd5547bbe6531813015f545ac17550ec44e9582c))
- Rework discovery API ([8949461](https://github.com/eclipse-thingweb/dart_wot/commit/894946138cf585eb3195fe163c7134eff3ced6b0))
- Enable GitHub Actions for merge queue ([d305525](https://github.com/eclipse-thingweb/dart_wot/commit/d30552514a7febd7a407f93ef873bc153dafb01b))
- Implement DNS-SD support ([6b19a16](https://github.com/eclipse-thingweb/dart_wot/commit/6b19a1628741ea926482af97ee1829696948064d))
- Bump version to 0.24.1 ([654d917](https://github.com/eclipse-thingweb/dart_wot/commit/654d9177a1412a70a127c1af78adcff759e4bade))

### Fixed

- Extract port from DNS SRV records ([9c520bd](https://github.com/eclipse-thingweb/dart_wot/commit/9c520bdb5a5397a748f9f7cba05f384e401a3304))

## [0.24.0] - 2023-01-29

### Added

- Address linting issue ([c17eae5](https://github.com/eclipse-thingweb/dart_wot/commit/c17eae567387276a25ca210f955fa6bac8e48e8a))

### Changed

- Implement new CoAP vocabulary terms ([0b83b53](https://github.com/eclipse-thingweb/dart_wot/commit/0b83b53bac5e902f65ef43b77f54aff48a50fc70))
- Move node-wot license to a separate file ([e1d1646](https://github.com/eclipse-thingweb/dart_wot/commit/e1d164611851890ca5afb94fadfcd73cd6bd4702))
- Bump version to 0.24.0 ([b3322b7](https://github.com/eclipse-thingweb/dart_wot/commit/b3322b7db2d081b79ea640819e88233edddbccee))

### Fixed

- Fix parsing of multiple context values ([ab46394](https://github.com/eclipse-thingweb/dart_wot/commit/ab46394248e33dad01f859da54855c18f178957d))
- Fix CoAP forms in complex example ([340aa2b](https://github.com/eclipse-thingweb/dart_wot/commit/340aa2b9aa4f67f6d0ef9cb8b9e0dfd30ecf4af5))
- Fix formatting of mocked classes ([86613c8](https://github.com/eclipse-thingweb/dart_wot/commit/86613c8d73c866bf0d7ab1253c1b0b606bc6627c))

## [0.23.1] - 2023-01-16

### Changed

- Update dependencies ([d6fbcda](https://github.com/eclipse-thingweb/dart_wot/commit/d6fbcda04c5d2f46cac0efe1e4d20e0fe5d7bd13))
- Adapt CoAP binding to new library API ([8756d27](https://github.com/eclipse-thingweb/dart_wot/commit/8756d2795e682370dc587c676e9d4fe5b92ae8c4))
- Bump version to 0.23.1 ([b68e902](https://github.com/eclipse-thingweb/dart_wot/commit/b68e902799a166705385d0aeb6ce5bb4b3d51709))

## [0.23.0] - 2022-10-19

### Added

- Add missing writeallproperties operation ([1586eda](https://github.com/eclipse-thingweb/dart_wot/commit/1586edabd18ef13c2f718064a027e0a797c9cf3a))

### Changed

- Bump version to 0.22.1 ([44be4b7](https://github.com/eclipse-thingweb/dart_wot/commit/44be4b7231a167369fa6349daaa6b3bad549dd15))
- Introduce DiscoveryContent class ([3ced172](https://github.com/eclipse-thingweb/dart_wot/commit/3ced1721492f0d1e106099fb65edc0453b779998))
- Improve formatting of CHANGELOG ([41f5fbb](https://github.com/eclipse-thingweb/dart_wot/commit/41f5fbb562f3ae5630e6bc39696d28d5e64cd1c5))
- Bump version to 0.23.0 ([3fc79f1](https://github.com/eclipse-thingweb/dart_wot/commit/3fc79f1cf5da412063f43cdf8e0ee3a0ffa3645f))

### Fixed

- Improve multicast discovery with CoRE Link-Format ([d1073b5](https://github.com/eclipse-thingweb/dart_wot/commit/d1073b5a644615fe9b7adfb000c36672d61f54d3))

## [0.22.0] - 2022-09-26

### Added

- Add additional JSON parser methods ([e02627a](https://github.com/eclipse-thingweb/dart_wot/commit/e02627a2a87d46400cad487d32eede00099d429c))
- Add missing Thing Description fields ([1b64214](https://github.com/eclipse-thingweb/dart_wot/commit/1b64214347764be80b2825ab0102469aa074b850))

### Changed

- Refactor JSON parser methods ([08e5dba](https://github.com/eclipse-thingweb/dart_wot/commit/08e5dbaaea1679fdcf84757d1a783e8c37e631e5))
- Refactor link parsing ([af4ef20](https://github.com/eclipse-thingweb/dart_wot/commit/af4ef205746da2fb596c8159830d832807a1fe15))
- Refactor parsing of interaction affordances ([5355557](https://github.com/eclipse-thingweb/dart_wot/commit/53555571993766354cb4b5ba7d8f618db7113790))
- Refactor URI parsing ([975e120](https://github.com/eclipse-thingweb/dart_wot/commit/975e12061335b3aee15c1358563ed6175fe083ec))
- Rework parsing of additional fields ([75009b8](https://github.com/eclipse-thingweb/dart_wot/commit/75009b8be432406968fc3dfb308db098cfa4ca8f))
- Replace scheme getters with final fields ([d75ce47](https://github.com/eclipse-thingweb/dart_wot/commit/d75ce47877424bd850ccace58ca87395e276ecac))
- Bump version to 0.22.0 ([58870ad](https://github.com/eclipse-thingweb/dart_wot/commit/58870adb739990214d724421bcea0db84df039a4))

### Fixed

- Rework interaction affordances and data schema ([d73af5f](https://github.com/eclipse-thingweb/dart_wot/commit/d73af5f701036d6e1c5a0ab3ecb182f2e9bea270))
- Make parsedFields parameter mandatory ([5ab8283](https://github.com/eclipse-thingweb/dart_wot/commit/5ab8283b3a121c45f30fd3c9dfc15c6f1b5e9ecd))

## [0.21.1] - 2022-09-22

### Changed

- Bump version to 0.21.1 ([c368075](https://github.com/eclipse-thingweb/dart_wot/commit/c368075cc900dd5802edb57e66fbc3f7019c9e94))

### Fixed

- Correctly parse String @context entries ([9edd402](https://github.com/eclipse-thingweb/dart_wot/commit/9edd40270ca12347a565f0afcee35bd74f0a0c64))

## [0.21.0] - 2022-09-22

### Added

- Add Codec for CoRE Link Format ([c96ad06](https://github.com/eclipse-thingweb/dart_wot/commit/c96ad067d1cd2de54a7533b31d338c9f907dc277))
- Add missing contentCoding field to form ([85f2548](https://github.com/eclipse-thingweb/dart_wot/commit/85f2548c8b89156386c8e190a2c9b2c189b350cb))
- Address linting issues ([7f93a7a](https://github.com/eclipse-thingweb/dart_wot/commit/7f93a7a1a4a0c181f52690e125726d7b5bdd27ce))
- Address remaining linting issues ([249f427](https://github.com/eclipse-thingweb/dart_wot/commit/249f427fc794ffe30d6624c24a3446baec07e9de))
- Add ACE-OAuth support ([bb47c03](https://github.com/eclipse-thingweb/dart_wot/commit/bb47c036f714bd42fb02cfa4eca32bc986914f7a))
- Add first version of MQTT binding ([181bf9a](https://github.com/eclipse-thingweb/dart_wot/commit/181bf9ab789063783bdf556368f5f81f73db4761))
- Add support for CoRE RD discovery ([48829ed](https://github.com/eclipse-thingweb/dart_wot/commit/48829ed39f26d97a805e52f2168f43eefb388bac))
- Add missing data schema fields ([629aafc](https://github.com/eclipse-thingweb/dart_wot/commit/629aafce2c2133a28779c2122d655e1f21ea984a))

### Changed

- Simplify codec registration system ([0c08529](https://github.com/eclipse-thingweb/dart_wot/commit/0c08529bb2decc2ae907f15185d0c94f6adff78f))
- Rework internal Discovery API and CoAP Binding ([4d6359c](https://github.com/eclipse-thingweb/dart_wot/commit/4d6359cb597bac817777bfbe07c211c372716db5))
- Update TD JSON Schema ([ce99142](https://github.com/eclipse-thingweb/dart_wot/commit/ce991420a936841d528e656a9493e754738b91db))
- Also run CI on macOS and Windows ([471e1a7](https://github.com/eclipse-thingweb/dart_wot/commit/471e1a7dc78ad3891a1cad897fa6b888bb9337fa))
- Improve ThingDescriptionValidationException ([8e57ae3](https://github.com/eclipse-thingweb/dart_wot/commit/8e57ae3f639fa78952dd94a531ed3ccd90bdfdca))
- Allow passing invalid credentials to security callbacks ([7c85a09](https://github.com/eclipse-thingweb/dart_wot/commit/7c85a09d8f55495e7a7a4f3937e5ec5f783e6659))
- Adjust coap binding to new library API ([b1b7214](https://github.com/eclipse-thingweb/dart_wot/commit/b1b72146dfa0b5b2462d1234091bd47385c11e8a))
- Ignore VS Code files ([bf83ce2](https://github.com/eclipse-thingweb/dart_wot/commit/bf83ce2977eb9dd6e4041c31b9b940df68303e1c))
- Mention MQTT support in README and pubspec ([ab94165](https://github.com/eclipse-thingweb/dart_wot/commit/ab941651ba25850374ab64b1a8002293728bca4c))
- Clean up CoRE Link Format discovery ([a540629](https://github.com/eclipse-thingweb/dart_wot/commit/a54062962dad20e3b9c24b8a93c8f7b570376d7f))
- Refactor ACE-OAuth error handling ([0bd0b6b](https://github.com/eclipse-thingweb/dart_wot/commit/0bd0b6ba1515cce6809902e7366b5c5a3da8c759))
- Rework data schema implementation ([506d20b](https://github.com/eclipse-thingweb/dart_wot/commit/506d20b9f5562359137d9325f66e12c85aaa66a0))
- Bump version to 0.21.0 ([882f407](https://github.com/eclipse-thingweb/dart_wot/commit/882f40767d26a38241f5b00a7fc56f647f5250e8))

### Fixed

- Fix documentation of AsyncClientSecurityCallback ([0041368](https://github.com/eclipse-thingweb/dart_wot/commit/00413688c2dc56125a51da34a6a3e37c8b1b59a3))
- Fix typos in README ([fbaf081](https://github.com/eclipse-thingweb/dart_wot/commit/fbaf08173974689c28b62c6dfc841d8017bc633a))
- Include uri-query in requests ([9c0b8f1](https://github.com/eclipse-thingweb/dart_wot/commit/9c0b8f1d0b50b70a5cc625b73d008969ed107c38))
- Allow multiple URI schemes during discovery ([73faf66](https://github.com/eclipse-thingweb/dart_wot/commit/73faf662591f56f423340a93634757cf94f9f41a))
- Check response code of CoAP responses ([a2e0654](https://github.com/eclipse-thingweb/dart_wot/commit/a2e0654646ac35dc44d449b93ed63644a09526b1))
- Fix typo in CHANGELOG ([904b4e8](https://github.com/eclipse-thingweb/dart_wot/commit/904b4e8d0305bf7c4cd8f5e17a38f67864a1d925))

## [0.20.1] - 2022-07-26

### Changed

- Let _discoverFromUnicast return a Stream ([fa1656f](https://github.com/eclipse-thingweb/dart_wot/commit/fa1656f79ed085da548e5b2364e154faf6f80c76))
- Update CoAP discovery example ([f0c3c81](https://github.com/eclipse-thingweb/dart_wot/commit/f0c3c81141abaad261ee11ed50560fb49143e7f3))
- Make input creation for content_serdes test more flexible ([b9402e7](https://github.com/eclipse-thingweb/dart_wot/commit/b9402e71aa3c6ebc37b444a6925305d7bcae2caf))
- Bump version to 0.20.1 ([d0aa348](https://github.com/eclipse-thingweb/dart_wot/commit/d0aa348491a64265991c4b713f1e025135bbe990))

### Fixed

- Return null for zero bytes payloads ([529c463](https://github.com/eclipse-thingweb/dart_wot/commit/529c46397edd742ef06fbe4a30f32dd9925343eb))
- Correctly set URI path for discovery ([678f423](https://github.com/eclipse-thingweb/dart_wot/commit/678f423312a0413110ebcf4162cdcad228c61105))
- Set accept to 40 for CoRE Link Format discovery ([3b2aa1c](https://github.com/eclipse-thingweb/dart_wot/commit/3b2aa1c24c8c0459d4d8a5e8e1308d44f43ff2f0))

## [0.20.0] - 2022-06-23

### Added

- Add data model for AutoSecurityScheme ([04db4f9](https://github.com/eclipse-thingweb/dart_wot/commit/04db4f9f1c910e7420f5a2f7e4e3e1fa347efa15))
- Add example for basic and auto security ([c76dc3b](https://github.com/eclipse-thingweb/dart_wot/commit/c76dc3ba6d169234c8aeba1ef121e0a4ec1e4705))

### Changed

- Set coap version to 4.1.0 ([3de8b8f](https://github.com/eclipse-thingweb/dart_wot/commit/3de8b8fbe0e6c80d419632367d163d03be730c7f))
- Bump version to 0.19.2 ([7709a33](https://github.com/eclipse-thingweb/dart_wot/commit/7709a338928cb5bf3d7f70ee6523d9054e9c8c61))
- Refactor HttpRequestMethod as enhanced enum ([8ae39df](https://github.com/eclipse-thingweb/dart_wot/commit/8ae39df6bb4401ed32f16083b7202ddb1852ad3f))
- Rework security implementation ([779d188](https://github.com/eclipse-thingweb/dart_wot/commit/779d1888b1f439c24c1e57fe3a0abf6251837cb7))
- Bump version to 0.20.0 ([4db8db5](https://github.com/eclipse-thingweb/dart_wot/commit/4db8db5a3ad22be30c0ababc0749fb5ffac03503))

### Fixed

- Rework content deserialization ([35e7725](https://github.com/eclipse-thingweb/dart_wot/commit/35e7725cf739fa79b99a9e6599d6646e54c55158))

## [0.19.1] - 2022-06-23

### Changed

- Bump version to 0.19.1 ([270d4e8](https://github.com/eclipse-thingweb/dart_wot/commit/270d4e8420b3535cf47df3795ca1714035bcfb96))

### Fixed

- Prevent CoRE Web Link from being fetched twice ([1e64a94](https://github.com/eclipse-thingweb/dart_wot/commit/1e64a9446a0e2c455701b24489a9a31273bd7b8e))

## [0.19.0] - 2022-06-12

### Added

- Add lint badge to README ([7b17499](https://github.com/eclipse-thingweb/dart_wot/commit/7b17499a8a4d8f00101a055cfba71379a143873a))

### Changed

- Use lint instead of strict_analyzer for linting ([4900290](https://github.com/eclipse-thingweb/dart_wot/commit/4900290f2a18616ad70c0b2582637337f24a7597))
- Use direct as default Discovery method ([cc752d6](https://github.com/eclipse-thingweb/dart_wot/commit/cc752d64c3be4dc5399f395a8c8dcdc567d535d0))
- Bump version to 0.19.0 ([296df88](https://github.com/eclipse-thingweb/dart_wot/commit/296df884e71fc96c8885e740fce8ad72bdfac616))

## [0.18.0] - 2022-06-12

### Added

- Add missing action fields ([e86b823](https://github.com/eclipse-thingweb/dart_wot/commit/e86b823084aa72e4b3671930dc122e5d00c9d43f))
- Add hreflang to Link class ([7d51463](https://github.com/eclipse-thingweb/dart_wot/commit/7d51463d3278e1ee7cc30a8c19fd3019397ca5c8))
- Add test for parsing properties ([de359bf](https://github.com/eclipse-thingweb/dart_wot/commit/de359bfae573959aa6fc7ca5403fccd171feddc6))
- Add missing toString() overrides to Exceptions ([582fa23](https://github.com/eclipse-thingweb/dart_wot/commit/582fa23d37150e8c339a1d6aef30177051ca3f4a))

### Changed

- Rework operationType definition ([95900ff](https://github.com/eclipse-thingweb/dart_wot/commit/95900ffe070c3237b1910ead02bc87a552058a0b))
- Refactor CoAP binding ([d55f8d8](https://github.com/eclipse-thingweb/dart_wot/commit/d55f8d899f17564ac060803a00cd81782f1bcd82))
- Reformat docstring ([76afa7f](https://github.com/eclipse-thingweb/dart_wot/commit/76afa7fdf9059590482a4ba93faa16fbc2749a23))
- Re-organize imports ([378bbbc](https://github.com/eclipse-thingweb/dart_wot/commit/378bbbc0a869cdd21b514913a6f6f3d801eaa936))
- Parse observable field ([5f903ae](https://github.com/eclipse-thingweb/dart_wot/commit/5f903aeafe3165aceab475322c4e97da2dbb0ad2))
- Implement AdditionalExpectedResponse class ([6a032f2](https://github.com/eclipse-thingweb/dart_wot/commit/6a032f2850f0141b1faa87796377d07e7b2dab7b))
- Refactor defaults of DigestSecurityScheme ([d5afd48](https://github.com/eclipse-thingweb/dart_wot/commit/d5afd488e5623458a27610f1cde8cd95b737e3e2))
- Parse more dataschema fields ([e9427f3](https://github.com/eclipse-thingweb/dart_wot/commit/e9427f3d2a08be1e8d1a226c5286d8faee961c78))
- Use and apply stricter lint config ([4098ac2](https://github.com/eclipse-thingweb/dart_wot/commit/4098ac262234475d7b916ee48823639f710e4a6f))
- Bump version to 0.18.0 ([1715ffa](https://github.com/eclipse-thingweb/dart_wot/commit/1715ffa3ad3c498a381f0b1b0178e2488a22554d))

### Fixed

- Print out value in coap_discovery example ([96b6ffd](https://github.com/eclipse-thingweb/dart_wot/commit/96b6ffdf0579faa497b992b2d1e6378fda8d983b))
- Use correct defaults for readOnly/writeOnly ([5f9cca3](https://github.com/eclipse-thingweb/dart_wot/commit/5f9cca3de3c350a0f11a4a46554454950dfd8dc9))
- Use Exceptions instead of Errors where appropriate ([7ba231f](https://github.com/eclipse-thingweb/dart_wot/commit/7ba231fe2605804e8768dcfdaf4831adac86040a))
- Adjust error types ([7f9505b](https://github.com/eclipse-thingweb/dart_wot/commit/7f9505b3a4874ea147599a872758405eadf9095d))

### Removed

- Remove explicit typing ([8e01e14](https://github.com/eclipse-thingweb/dart_wot/commit/8e01e149822409f11a50251736e2dcd3da9f5239))

## [0.17.0] - 2022-06-12

### Added

- Add validation of Thing Descriptions ([7af7429](https://github.com/eclipse-thingweb/dart_wot/commit/7af7429c71fc23ff82c70a2479d8dac97260987e))
- Add tests for Thing Description validation ([255a116](https://github.com/eclipse-thingweb/dart_wot/commit/255a1167ac020ffde07ad4e69ea46a1bf48acb00))
- Add basic CoRE Resource Discovery example ([05ce26e](https://github.com/eclipse-thingweb/dart_wot/commit/05ce26e7db43d214b058e0949a38accbb3e359a0))

### Changed

- Replace json_schema2 with json_schema3 ([72c1002](https://github.com/eclipse-thingweb/dart_wot/commit/72c10024c6160c918abf4cd68b588f0e456d4c36))
- Implement basic CoRE Resource Discovery ([6def243](https://github.com/eclipse-thingweb/dart_wot/commit/6def2439308bb618b541ef5cf1d878b5e5ba78c9))
- Update version to 0.17.0 ([ed5fba9](https://github.com/eclipse-thingweb/dart_wot/commit/ed5fba9b56d50c34cab182dcdd0950717b4ecab1))

### Fixed

- Fix cobertura report in CI pipeline ([8eb7d16](https://github.com/eclipse-thingweb/dart_wot/commit/8eb7d1671815a9b73ff8f7b356e9eb49acd5a16a))
- Override == and hashCode for ContextEntry ([13aa00c](https://github.com/eclipse-thingweb/dart_wot/commit/13aa00cd7012afa7a4827200da6ded624ea5bfdb))
- Throw ValidationException instead of ArgumentError ([7834548](https://github.com/eclipse-thingweb/dart_wot/commit/7834548d3988aa322e58675c34d8b51faee15e78))

### Removed

- Remove any and multicast discovery methods ([a9fac10](https://github.com/eclipse-thingweb/dart_wot/commit/a9fac1014e5bcef9ddef2756d2d7a8c565baf929))

## [0.16.0] - 2022-05-30

### Added

- Add ValidationException class ([7a5eff3](https://github.com/eclipse-thingweb/dart_wot/commit/7a5eff39e437bcaf2e2343c02bc21365b2d6dfb4))

### Changed

- Simplify form augmentation ([aa4c90b](https://github.com/eclipse-thingweb/dart_wot/commit/aa4c90b09dbfa90b46d47530bf1e0ae6f9c60530))
- Rework direct Discovery ([fa78a10](https://github.com/eclipse-thingweb/dart_wot/commit/fa78a10a562c3d508f14414b66c6678062e49dac))
- Rework credentials system ([a381f7d](https://github.com/eclipse-thingweb/dart_wot/commit/a381f7dc22c49e6aa843c8da1b0cfe927d06fccf))
- Update examples ([b285bc1](https://github.com/eclipse-thingweb/dart_wot/commit/b285bc193bf43bc6df74cc0b73bfdb29793668e2))
- Bump version to 0.16.0 ([cb3932f](https://github.com/eclipse-thingweb/dart_wot/commit/cb3932f5af64be77fbace710b245999384885c3f))

### Fixed

- Make DiscoveryException actually usable ([2b7d029](https://github.com/eclipse-thingweb/dart_wot/commit/2b7d02937693c985a9026e0ea50ae86de875f20d))
- Fix subscription implementation for CoAP ([58f80c4](https://github.com/eclipse-thingweb/dart_wot/commit/58f80c4fc501d9a533a252feb69fdbef78db6457))

## [0.15.1] - 2022-05-22

### Changed

- Bump version to 0.15.1, update changelog ([cf6b62b](https://github.com/eclipse-thingweb/dart_wot/commit/cf6b62bbb762aedebf50a15f1a280333ba824178))

### Fixed

- Update CoAP vocabulary in example ([36c950b](https://github.com/eclipse-thingweb/dart_wot/commit/36c950b28468b2ee4567bd594ca77d8302214580))

## [0.15.0] - 2022-05-21

### Added

- Add basic CURIE expansion for additional fields ([8125436](https://github.com/eclipse-thingweb/dart_wot/commit/8125436160e2bc813059b7fadc4ebed52df0ead1))
- Add (experimental) coaps support ([40c7b96](https://github.com/eclipse-thingweb/dart_wot/commit/40c7b96f6b14739fce79df0d24145655c25d5b3d))
- Add example for CoAPS usage ([cc49453](https://github.com/eclipse-thingweb/dart_wot/commit/cc494536e01a33745346a322f13698abbc39c097))
- Add CoAPS to package description ([baf517d](https://github.com/eclipse-thingweb/dart_wot/commit/baf517d36acd300ae650d6c6d6a5d2664ad5bb66))

### Changed

- Require dart 2.17 ([e9faea7](https://github.com/eclipse-thingweb/dart_wot/commit/e9faea7bef96f72bc886d56a99046d3faf91cbd5))
- Rework CoAP binding ([822db4f](https://github.com/eclipse-thingweb/dart_wot/commit/822db4febdbd9decf7d417969f5c84fe0d6717aa))
- Bump version to 0.15.0, update changelog ([f8f7174](https://github.com/eclipse-thingweb/dart_wot/commit/f8f717468b9c2136bf1714a53cf255d673c62e5f))

### Fixed

- Fix Gitlab CI pipeline ([a383683](https://github.com/eclipse-thingweb/dart_wot/commit/a38368350dbadf37f8088d99675340374a35f7e6))
- Fix Github CI pipeline ([f150463](https://github.com/eclipse-thingweb/dart_wot/commit/f150463df622f894cf28a24b24388fab9786fdec))

### Removed

- Remove coaps as a feature to add in the future ([dfb0476](https://github.com/eclipse-thingweb/dart_wot/commit/dfb0476c43b6ba97ff0424448b1264f2fe6cdced))

## [0.14.0] - 2022-03-27

### Changed

- Improve url field documentation ([803ba24](https://github.com/eclipse-thingweb/dart_wot/commit/803ba245f589789238ba03846a1c3a3d3a173fe7))
- Bump version to 0.14.0 ([cd32118](https://github.com/eclipse-thingweb/dart_wot/commit/cd321185a049a23af15a69e844f0a0c5fa9bde37))

### Fixed

- Align ThingFilter class with specification ([87a106a](https://github.com/eclipse-thingweb/dart_wot/commit/87a106abf4737058a25c6d93eaf91948923e2bc2))

### Removed

- Remove TODO ([2836649](https://github.com/eclipse-thingweb/dart_wot/commit/2836649ab9022cbd5aac0b4979b6176b1e1c4759))

## [0.13.0] - 2022-03-27

### Added

- Add mockito and build_runner ([a1d3fee](https://github.com/eclipse-thingweb/dart_wot/commit/a1d3feeec080ca32e67116e4358d445b3f4b16b8))
- Add UnimplementedError to start and stop ([3819b8b](https://github.com/eclipse-thingweb/dart_wot/commit/3819b8b78cc45a916222adc24c2f40a5ea6ab5ff))
- Add server tests ([f3dba12](https://github.com/eclipse-thingweb/dart_wot/commit/f3dba12a181126185ce99e6eff547252aa50130b))
- Add client factory tests ([c9e4e62](https://github.com/eclipse-thingweb/dart_wot/commit/c9e4e6267c79e72df34d27169ff780060af720ea))
- Add server tests ([37aac32](https://github.com/eclipse-thingweb/dart_wot/commit/37aac32ffd539379ed70377d5cd208f9013c55d4))
- Add pub.dev badge to README ([fc792c3](https://github.com/eclipse-thingweb/dart_wot/commit/fc792c36b56b02eff7eccc5f1b7b0032a5a9dca8))
- Add cleanup methods ([a1c2f90](https://github.com/eclipse-thingweb/dart_wot/commit/a1c2f90dc0a2dc87aa06a3710cb9f126a361a667))

### Changed

- Make port and scheme final ([16c6c47](https://github.com/eclipse-thingweb/dart_wot/commit/16c6c479b70ea0a48331d138579766f56b9027fd))
- Get blocksize from config ([4b22c02](https://github.com/eclipse-thingweb/dart_wot/commit/4b22c02a2c6be4223e8988c37560dc9844025699))
- Simplify  getters ([dfd2fd8](https://github.com/eclipse-thingweb/dart_wot/commit/dfd2fd8854b190ea62f110289a05ec8f18bc60e4))
- Move test files into subfolders ([c6e3af2](https://github.com/eclipse-thingweb/dart_wot/commit/c6e3af20a3b6cf9fad60870569754411dd3f1017))
- Rework credentials system ([7f3c0ed](https://github.com/eclipse-thingweb/dart_wot/commit/7f3c0edd5f352ec942a5e430a85ecee505ef0f4a))
- Bump version to 0.13.0 ([918853b](https://github.com/eclipse-thingweb/dart_wot/commit/918853b79064d64ad31d93e6a1fd2052596ac79e))

### Fixed

- Set growable: false for unmutable lists ([9915b71](https://github.com/eclipse-thingweb/dart_wot/commit/9915b71816b468281a80f548317636fd3da5a26f))
- Make shutdown serverStatuses growable ([dcd455e](https://github.com/eclipse-thingweb/dart_wot/commit/dcd455e4ba7e225a5dd566b338202c1ecdf11a37))
- Test ConsumedThing destruction ([fe1a63d](https://github.com/eclipse-thingweb/dart_wot/commit/fe1a63d27744d60df39ad1b83c590de1d4fffb74))
- Let WoT class only expose Scripting API interfaces ([7c94267](https://github.com/eclipse-thingweb/dart_wot/commit/7c94267f699b2fe1ad1a7f8f5c2b448ea36381b2))
- Fix test and example after API change ([1b3d5cb](https://github.com/eclipse-thingweb/dart_wot/commit/1b3d5cb2c8c0ccc7a9d87d8ce73696624c95a002))

### Removed

- Remove obsolete null parameters in examples ([784d4cb](https://github.com/eclipse-thingweb/dart_wot/commit/784d4cb3ed7560e959889a0705be699aae7e16fc))

## [0.12.1] - 2022-03-21

### Added

- Add README example to example folder ([b6ecb98](https://github.com/eclipse-thingweb/dart_wot/commit/b6ecb980a609e3c6555c3d78e7ce14f80a0f7d59))

### Changed

- Rename dart_wot_example to complex_example ([2f6acd1](https://github.com/eclipse-thingweb/dart_wot/commit/2f6acd1e419136b7941323f8ee4991b674444a66))
- Update example in README ([b85ce9c](https://github.com/eclipse-thingweb/dart_wot/commit/b85ce9c41788d2ec2edfa30029880ed96c63f956))
- Bump version to 0.12.1 ([812bddc](https://github.com/eclipse-thingweb/dart_wot/commit/812bddc568be58d4566acbbeb6f6b2cf66a93ad5))

## [0.12.0] - 2022-03-21

### Added

- Add JSON schema validation of values ([529d6f4](https://github.com/eclipse-thingweb/dart_wot/commit/529d6f49eed5c7f71a102e19e668f04de0e4d8c5))
- Add tests for JSON schema validation of values ([f1b9584](https://github.com/eclipse-thingweb/dart_wot/commit/f1b95845bf505f4365a2b62d575c03acc7f6b550))
- Add support for global URI variables ([b3cf61b](https://github.com/eclipse-thingweb/dart_wot/commit/b3cf61bbb3619e9ffcad9bb5c8c8910868340dc9))

### Changed

- Update README file ([8b46ccf](https://github.com/eclipse-thingweb/dart_wot/commit/8b46ccf0f8dcda5223d98ba3bdcec7ddfe63a6a9))
- Bump version to 0.12.0 ([2e91a8f](https://github.com/eclipse-thingweb/dart_wot/commit/2e91a8fb4abd90e96c44c97f793ac30eddf95b9f))

### Fixed

- Include global URI variables in test ([df0d17b](https://github.com/eclipse-thingweb/dart_wot/commit/df0d17b94c8aaa6d578459fafcf8984c523b1cf1))

## [0.11.1] - 2022-03-14

### Changed

- Update example in README.md ([bee9a1e](https://github.com/eclipse-thingweb/dart_wot/commit/bee9a1e22ae015e3381a5b76b9ac870aa553f32b))
- Bump version to 0.11.1 ([59e5a31](https://github.com/eclipse-thingweb/dart_wot/commit/59e5a3197b86f35466c78552a7a92d1b007d07cc))

## [0.11.0] - 2022-03-14

### Added

- Add json_schema2 and uri ([22ee3f1](https://github.com/eclipse-thingweb/dart_wot/commit/22ee3f10f46d635a8b32d3a4ce13bfaa37b90dc2))
- Add URI variable tests ([1725d47](https://github.com/eclipse-thingweb/dart_wot/commit/1725d47b20bc6256ed8df0c7eadafb96d21b5641))
- Add uriVariables to example ([ad3e5a6](https://github.com/eclipse-thingweb/dart_wot/commit/ad3e5a6e79aa26ba30ccdd93a43c790125f8e2be))

### Changed

- Parse uriVariables at the affordance level ([d5dd268](https://github.com/eclipse-thingweb/dart_wot/commit/d5dd268c05f116515ef4ad09f7d575980eb5ab6e))
- Make shallow copy of securityDefinitions ([881ace9](https://github.com/eclipse-thingweb/dart_wot/commit/881ace9600434edd61966eee532659918115a19a))
- Pass affordances to _getClientFor ([99a5281](https://github.com/eclipse-thingweb/dart_wot/commit/99a52817f2f388952f0831c3639219b551053e53))
- Rework interaction_options ([90fa067](https://github.com/eclipse-thingweb/dart_wot/commit/90fa067932de3349ea24754e1e8647c5f8f5cc46))
- Implement handling of uriVariables ([2a3558a](https://github.com/eclipse-thingweb/dart_wot/commit/2a3558a74b9d4e0f78d6ee572dbc37c2da1b8296))
- Bump cbor to version 5.0.0 ([26f8f32](https://github.com/eclipse-thingweb/dart_wot/commit/26f8f32bb7225a08682de7d12da9a296f144f402))
- Bump coap to version 3.5.0 ([3dadbe6](https://github.com/eclipse-thingweb/dart_wot/commit/3dadbe6776df2cac78b4b7d410142681773d59bb))
- Use simplified cbor API in codec ([f0db171](https://github.com/eclipse-thingweb/dart_wot/commit/f0db171e940f0930ed869f29c0cd4c95c2417e62))
- Bump version to 0.11.0 ([fa99765](https://github.com/eclipse-thingweb/dart_wot/commit/fa99765aca467763c1885b3d045d4960d5900170))

### Fixed

- Fix small error in example ([a6358a3](https://github.com/eclipse-thingweb/dart_wot/commit/a6358a31c8f55dc0bbf9cb85922fa3e1db250e81))
- Close library client after requests ([e2cffc4](https://github.com/eclipse-thingweb/dart_wot/commit/e2cffc4b3a362c2a690b312bcd338a13ecb7d146))

### Removed

- Remove unneeded exit(0) from example ([6a8df58](https://github.com/eclipse-thingweb/dart_wot/commit/6a8df584376fa989a04c5b3c7c93200bdd6cd341))
- Remove unneeded null check ([36fe7ca](https://github.com/eclipse-thingweb/dart_wot/commit/36fe7ca0b224ec709388a510f92682fc3ec4824e))
- Remove unused definitions ([dc6f851](https://github.com/eclipse-thingweb/dart_wot/commit/dc6f851eb2b631dcb16ea931c88b848c608c8b3d))

## [0.10.0] - 2022-03-11

### Added

- Add CredentialsScheme interface ([43f2457](https://github.com/eclipse-thingweb/dart_wot/commit/43f2457ef03e3ee031c74015cb12ef5b8d78bac5))
- Add digest and bearer support ([4c12d5b](https://github.com/eclipse-thingweb/dart_wot/commit/4c12d5b376aab30d89ba38ceea59c335fc738aa3))
- Add security documentation ([44aee60](https://github.com/eclipse-thingweb/dart_wot/commit/44aee606b5feb4b144f2246f1bee15d18ad34c84))
- Add tests for Security Schemes ([9a53546](https://github.com/eclipse-thingweb/dart_wot/commit/9a5354683343e2bb56959e30a2d58bb59a4ca360))

### Changed

- Add http_auth as a dependency ([6439f1b](https://github.com/eclipse-thingweb/dart_wot/commit/6439f1babccf574a11d6110edb53633fcae51719))
- Expand addCredentials documentation ([5115a56](https://github.com/eclipse-thingweb/dart_wot/commit/5115a56aab275f866d7b6e6951c5efa1d589b4bb))
- Bump version to 0.10.0 ([0cafe7d](https://github.com/eclipse-thingweb/dart_wot/commit/0cafe7d882bf5c7eae49cdbc30d73eaa077d32c0))

### Removed

- Remove "as" from http import ([47a2718](https://github.com/eclipse-thingweb/dart_wot/commit/47a271812aa78dc69c8550eba527a9db80dd78a9))

## [0.9.0] - 2022-02-23

### Added

- Add TODO for handling of Credentials ([a30a2a9](https://github.com/eclipse-thingweb/dart_wot/commit/a30a2a97ed610365ce3b5c04a0f4473f1afb733e))
- Add error message ([9491f9e](https://github.com/eclipse-thingweb/dart_wot/commit/9491f9e4f8b7fcf07b8f3949e536e25cf4ec1f8a))

### Changed

- Rework subscribeResource API ([6893e03](https://github.com/eclipse-thingweb/dart_wot/commit/6893e03ef44becdf5383248bcecf45b64fa410f4))
- Refactor _createSubscription method ([22788f0](https://github.com/eclipse-thingweb/dart_wot/commit/22788f01e72d60c6893b088ec9fc32f6e6ecad40))
- Refactor subscription helpers ([8a7b92b](https://github.com/eclipse-thingweb/dart_wot/commit/8a7b92b18301ad659555737f92cadc526fb8061f))
- Rename _deregisterObservation ([af36b2e](https://github.com/eclipse-thingweb/dart_wot/commit/af36b2ee09a3446418609dcb1ee751a4548c1399))
- Refactor op type defaults ([b0203a0](https://github.com/eclipse-thingweb/dart_wot/commit/b0203a0c834d2225cac4ac49f6db203f448f96ce))
- Clean up TODOs ([3b99b87](https://github.com/eclipse-thingweb/dart_wot/commit/3b99b874f627ba29812364258145b2e876455f81))
- Bump coap to version 3.4.0 ([354d992](https://github.com/eclipse-thingweb/dart_wot/commit/354d992d4045412439c51824731b0250d9b521e5))
- Bump version to 0.9.0 ([dbe5972](https://github.com/eclipse-thingweb/dart_wot/commit/dbe59720e7eadb9ff220500700f38bac665620dc))

### Fixed

- Fix documentation of OAuth2 flow field ([3b18074](https://github.com/eclipse-thingweb/dart_wot/commit/3b18074ca4340e2cf22644100b22cb0cae337f79))
- Don't catch all subscribe exceptions ([d5c2226](https://github.com/eclipse-thingweb/dart_wot/commit/d5c2226c0f4c9c46b8c0bf13cf0b21583b4d43aa))
- Set default contentType to application/json ([8920ac3](https://github.com/eclipse-thingweb/dart_wot/commit/8920ac389181012fb518ad6c3985f1eebfad8457))
- Make fields final ([fb50e98](https://github.com/eclipse-thingweb/dart_wot/commit/fb50e98ce584d3f65b8d3d0d02f1f6f397d396e8))

### Removed

- Remove identifier from OAuth2Credentials ([28ecfe0](https://github.com/eclipse-thingweb/dart_wot/commit/28ecfe095ad5679b47579385901ba2df9ee5794b))
- Remove obsolete TODO comments ([1abdd0a](https://github.com/eclipse-thingweb/dart_wot/commit/1abdd0a1ba2f8f4831d2ea6cc6c81c92a2eed343))
- Remove unused import ([ff4f1de](https://github.com/eclipse-thingweb/dart_wot/commit/ff4f1de051dff67853e8531a7215b699d2b46136))

## [0.8.0] - 2022-02-10

### Changed

- Re-align discovery API with current spec ([70a4377](https://github.com/eclipse-thingweb/dart_wot/commit/70a43770f2efc384ef2739977636c8ccac3abcf4))
- Use reworked discovery API in example ([bfd81e7](https://github.com/eclipse-thingweb/dart_wot/commit/bfd81e79008937431d7b46d416d6fab0af9085f4))
- Increment package version to 0.8.0 ([c6882ee](https://github.com/eclipse-thingweb/dart_wot/commit/c6882ee6ff57901a9383be9ff024cf45c06a3913))

## [0.7.1] - 2022-02-03

### Added

- Add missing OAuth2Credentials class ([9db3379](https://github.com/eclipse-thingweb/dart_wot/commit/9db337977befbdcdd9583804dfaf7960ccf4a2f3))

### Changed

- Increment package version to 0.7.1 ([00f525b](https://github.com/eclipse-thingweb/dart_wot/commit/00f525b9f34e0c1861bb4a4ede4bab74ba244334))

## [0.7.0] - 2022-02-03

### Added

- Add test for links field ([8ddadfb](https://github.com/eclipse-thingweb/dart_wot/commit/8ddadfb43c605f12da9c3b755524c4b0ffc5740e))
- Add test for parsing of security field ([be445ff](https://github.com/eclipse-thingweb/dart_wot/commit/be445ff18b8787ba01e4db15694cc8bd87b550c2))
- Add tests for Form defiinitions ([5ff6163](https://github.com/eclipse-thingweb/dart_wot/commit/5ff61632a122dc1c349e5a7bd7a4b9c5592e95dc))
- Add late keyword back to href ([5eea939](https://github.com/eclipse-thingweb/dart_wot/commit/5eea9396e6ec298ae2066b8eaa05ce145901c579))
- Add tests for creating Forms from JSON ([fc80bc4](https://github.com/eclipse-thingweb/dart_wot/commit/fc80bc482c7d75d166f76f70ed7a2ece436abc42))
- Add documentation to Servient class ([aafdde7](https://github.com/eclipse-thingweb/dart_wot/commit/aafdde76dccc6764b853f74aaed0bc42b2beeb3e))
- Add Basic Security Scheme ([8a21c16](https://github.com/eclipse-thingweb/dart_wot/commit/8a21c16a19f6e2331ee95fc0e0212b1869a85b8f))
- Add basic credentials ([76333eb](https://github.com/eclipse-thingweb/dart_wot/commit/76333eb9bb94c5958a103f60d1143baf9763b056))
- Add Basic Security to Example ([4d584bb](https://github.com/eclipse-thingweb/dart_wot/commit/4d584bba0d84f1e67a090f78d36aa8c88b50caca))
- Add PskSecurityScheme and Credentials ([c33f248](https://github.com/eclipse-thingweb/dart_wot/commit/c33f24858ff3c79d8635302e861521a1c0288881))
- Add DigestSecurityScheme and Credentials ([ef85dd7](https://github.com/eclipse-thingweb/dart_wot/commit/ef85dd7efc25033a8d6d6006bc1fb75d8376f38d))
- Add ApiKeySecurityScheme and Credentials ([f48db57](https://github.com/eclipse-thingweb/dart_wot/commit/f48db57b5f90469773e84c7708e7e6693b51312c))
- Add base URL as ID fallback ([3edaa3a](https://github.com/eclipse-thingweb/dart_wot/commit/3edaa3abb76c5b0f73880a07d9730ebf9af0364b))
- Add BearerSecurityScheme and Credentials ([2065338](https://github.com/eclipse-thingweb/dart_wot/commit/206533862944c7073fe388db7b9f833bf1865f55))
- Add OAuth2SecurityScheme ([5886778](https://github.com/eclipse-thingweb/dart_wot/commit/58867787459c15dd9488ccf5087ca072559685de))

### Changed

- Let TD parse links field ([cb6e35e](https://github.com/eclipse-thingweb/dart_wot/commit/cb6e35e79296d07c9c0211d4f9b7a490743947aa))
- Rework security APIs ([230d31b](https://github.com/eclipse-thingweb/dart_wot/commit/230d31b32fa91ac86fdcffac0e12128aa58bdcc1))
- Apply basic security to headers ([0b243e8](https://github.com/eclipse-thingweb/dart_wot/commit/0b243e80db9e5944de8b38290b3ff7fd0c78ccf2))
- Parse form href only once ([70175c2](https://github.com/eclipse-thingweb/dart_wot/commit/70175c2c3c656ed676bcf00102500e9a89eb3b46))
- Update project "Roadmap" in README ([6aab292](https://github.com/eclipse-thingweb/dart_wot/commit/6aab292297fa5e0c0c362de458b058f6f78c02f9))
- Increment package version to 0.7.0 ([c7a08f5](https://github.com/eclipse-thingweb/dart_wot/commit/c7a08f5d849c1befe2391aa4b5c35c26d09cf0c7))

### Fixed

- Make List and Map fields final in TD and Form ([a612506](https://github.com/eclipse-thingweb/dart_wot/commit/a612506d622b79a1c1c5b409d8416abf0b53507c))
- Fix parsing of security field ([bce9342](https://github.com/eclipse-thingweb/dart_wot/commit/bce9342083b71087cede05bb8967122534a64edf))
- Use named parameters for optional fields ([fef084e](https://github.com/eclipse-thingweb/dart_wot/commit/fef084e465f1e84dd590febd93231856f14d7b2f))
- Use named Form parameter ([47ef013](https://github.com/eclipse-thingweb/dart_wot/commit/47ef0137aeaddb9a078cb68214baa67565f49823))
- Correctly parse lists of security keys ([b187a61](https://github.com/eclipse-thingweb/dart_wot/commit/b187a6181317a4b4ac3480e15c84bb9a1f393fd9))
- Correctly parse lists of scopes ([5379081](https://github.com/eclipse-thingweb/dart_wot/commit/5379081c7b491ef95b76505e0aa9c7ce0d3082e0))
- Improve tests for SecurityScheme parsing ([7b24502](https://github.com/eclipse-thingweb/dart_wot/commit/7b24502c88db4b0445d4c99157d04d98882a5cf9))

### Removed

- Remove "ignore: unused_field" comment ([4f19bff](https://github.com/eclipse-thingweb/dart_wot/commit/4f19bffe5aa922f8ed1b01b4cd4053f40091cff6))

## [0.6.1] - 2022-01-20

### Changed

- Parse titles and descriptions at Thing level ([a523560](https://github.com/eclipse-thingweb/dart_wot/commit/a523560e0fbd03f2d0770f24c8b4269312b09d84))
- Increment package version to 0.6.1 ([797ae26](https://github.com/eclipse-thingweb/dart_wot/commit/797ae26a1ef2d3620f1d4d4b7f00fcdc7d223bf3))

## [0.6.0] - 2022-01-19

### Added

- Add BSD license to copyright headers ([2a8be57](https://github.com/eclipse-thingweb/dart_wot/commit/2a8be57acc9c0067816229f1f388913abd410b9c))
- Add BSD license to README file ([1d1caa1](https://github.com/eclipse-thingweb/dart_wot/commit/1d1caa16afedc2c7e008b941db784c176654bb59))

### Changed

- Replace licenses with BSD license ([6c87b4f](https://github.com/eclipse-thingweb/dart_wot/commit/6c87b4f8ed2b0f52b7e73397ad1d114a6eaf40e4))
- Increment package version to 0.6.0 ([199e870](https://github.com/eclipse-thingweb/dart_wot/commit/199e87064b08bbee43a88ebaa75887a973e2f077))

## [0.5.0] - 2022-01-18

### Added

- Add tests for parsing of titles and descriptions ([df0aef2](https://github.com/eclipse-thingweb/dart_wot/commit/df0aef2d33b8765c9a2fcb2fe05c2204c1592d26))
- Add subscription op types ([e4ef28e](https://github.com/eclipse-thingweb/dart_wot/commit/e4ef28ebc47c37421417f28a0b4a81e86c3b7562))
- Add toShortString method ([68caba9](https://github.com/eclipse-thingweb/dart_wot/commit/68caba9756943daa5d2fefc3254aac433278dd87))
- Add findUnsubscribeForm helper ([4448830](https://github.com/eclipse-thingweb/dart_wot/commit/4448830bb01b50b959ecddcf6d07be52ff0be221))
- Add DataSchema fields to Event class ([b6c79a7](https://github.com/eclipse-thingweb/dart_wot/commit/b6c79a738fb50a8b043b04f00e1887246b2d0e15))
- Add property observation to example file ([9398f4e](https://github.com/eclipse-thingweb/dart_wot/commit/9398f4edac540c94d019baadd8e4112f14ce1830))

### Changed

- Parse affordance title(s) and description(s) ([9ae5ab4](https://github.com/eclipse-thingweb/dart_wot/commit/9ae5ab41117ec981dd5c2b4dfd02366a19bc2dd1))
- Let Client Factories support multiple schemes ([c41fb74](https://github.com/eclipse-thingweb/dart_wot/commit/c41fb7419077bb17d14b1e169d9de0665446b514))
- Parse op values of Forms ([c994ee0](https://github.com/eclipse-thingweb/dart_wot/commit/c994ee01be36a406cd9960d99c4537c313fc1bcb))
- Copy more fields of Form class ([3485b30](https://github.com/eclipse-thingweb/dart_wot/commit/3485b3004002634d64cded6eacd3d4720d2ce38b))
- Clean up Subscription interface ([0cfcf72](https://github.com/eclipse-thingweb/dart_wot/commit/0cfcf72c5758a8e60210ff6971cdbe03e6fbe357))
- Implement subscription interfaces ([60354a5](https://github.com/eclipse-thingweb/dart_wot/commit/60354a5a9081a674b13cfae3aedb8364d1ae0d32))
- Implement subscription API ([05f1de1](https://github.com/eclipse-thingweb/dart_wot/commit/05f1de1e2291eeb7fcab74ffe8741e87354e44b7))
- Adjust according to subscription API ([71c07cf](https://github.com/eclipse-thingweb/dart_wot/commit/71c07cf714877c028a3804d9e242a700810f8248))
- Implement missing write and read methods ([9961973](https://github.com/eclipse-thingweb/dart_wot/commit/9961973212ec978544a973690da7e44fa49d3ff4))
- Turn ThingFilter into concrete class ([2b0f54f](https://github.com/eclipse-thingweb/dart_wot/commit/2b0f54ff390a29461b09450bb5de3694afabb7b1))
- Implement basic Discovery API version ([e3355cc](https://github.com/eclipse-thingweb/dart_wot/commit/e3355ccf437c0cdc488f4de841e2142a1cec3972))
- Update example with Discovery features ([886adfb](https://github.com/eclipse-thingweb/dart_wot/commit/886adfbcfc3f53087deedb79467819d06a32ce99))
- Increment package version to 0.5.0 ([c1d2bea](https://github.com/eclipse-thingweb/dart_wot/commit/c1d2beadea415c0b2714226eb8cb0b0c684008fb))

### Fixed

- Replace generic with concrete Exceptions ([4f1bfb8](https://github.com/eclipse-thingweb/dart_wot/commit/4f1bfb89c78963fd283b0898e688283379b12d6c))
- Fix doc comment of client factory ([67e0da3](https://github.com/eclipse-thingweb/dart_wot/commit/67e0da36ea0ddeb4693b053e6186e36729f314c3))

### Removed

- Remove unsubscribeResource method ([8a9a1b0](https://github.com/eclipse-thingweb/dart_wot/commit/8a9a1b0c1469185a232d305509bf66dbee7f2eae))
- Remove unused import ([e8418b4](https://github.com/eclipse-thingweb/dart_wot/commit/e8418b404939fb7e6f368bb58e932e8e023f833d))

## [0.4.0] - 2022-01-09

### Added

- Add http package as dependency ([200bc62](https://github.com/eclipse-thingweb/dart_wot/commit/200bc62dd2bccaf02dd8d414c93b231c227faf20))

### Changed

- Display code coverage in Gitlab CI ([cd5da7d](https://github.com/eclipse-thingweb/dart_wot/commit/cd5da7d5a81dd486de0c80a35a97d5309f071bf6))
- Create correct coverage.xml for Gitlab ([2cfe48e](https://github.com/eclipse-thingweb/dart_wot/commit/2cfe48ea42e696fa44973af7b77d9ef7f19600e5))
- Use named import for CoAP lib ([e5e1ff5](https://github.com/eclipse-thingweb/dart_wot/commit/e5e1ff5bde2b5ffb73f5fa80c20af75565cd8d89))
- Use config for requests directly ([1602f23](https://github.com/eclipse-thingweb/dart_wot/commit/1602f23f755d39de47dbc84186f5ba1e513649e8))
- Use getter for scheme field ([a0c67b2](https://github.com/eclipse-thingweb/dart_wot/commit/a0c67b29d21c9860168ca5131a447ee82d0df9b8))
- Use relative instead of package imports ([7ee69ab](https://github.com/eclipse-thingweb/dart_wot/commit/7ee69ab18718a32ac7acfe7560ee5a59b8fd5cec))
- Make configs optional params ([c64c5c3](https://github.com/eclipse-thingweb/dart_wot/commit/c64c5c356d0565d75c7c2b01b6b0c161b25cd646))
- Implement first version of HTTP(S) binding ([8d0da46](https://github.com/eclipse-thingweb/dart_wot/commit/8d0da464199b23da1bf3fe71a76013bd2d525374))
- Include HTTP binding in example ([7b5d6bb](https://github.com/eclipse-thingweb/dart_wot/commit/7b5d6bb974d5bdac93bdd1aa874a2a720698415a))
- Export HTTP library ([34aeb00](https://github.com/eclipse-thingweb/dart_wot/commit/34aeb0032eab77c35d11009f62a8207e16a2e168))
- Update README with HTTP binding ([53309de](https://github.com/eclipse-thingweb/dart_wot/commit/53309de57c151796ecb913329f07382fd3bdab62))
- Update package description ([db85cdb](https://github.com/eclipse-thingweb/dart_wot/commit/db85cdbf17bedd0f33578acd231ca782d3768658))
- Increment package version to 0.4.0 ([bd457d5](https://github.com/eclipse-thingweb/dart_wot/commit/bd457d57f8db0fbbee80c3d07ed28d53b5d194c7))

### Removed

- Remove unneeded return ([9ed98bd](https://github.com/eclipse-thingweb/dart_wot/commit/9ed98bd9ac72a1f0e93781d4b106707e9f2abddf))

## [0.3.0] - 2022-01-04

### Added

- Add coverage as dev dependency ([2e47e1b](https://github.com/eclipse-thingweb/dart_wot/commit/2e47e1bdffcb51b51679de18b89f06bd47891e30))
- Add Github Actions Workflow ([657fead](https://github.com/eclipse-thingweb/dart_wot/commit/657feadd0f5baf2c23db13fb30562d3313003109))
- Add Github Actions badge to README ([5ac6714](https://github.com/eclipse-thingweb/dart_wot/commit/5ac67142bf0cf5e712b59c4ab872c568316c21aa))
- Add codecov badge to README ([40d1e01](https://github.com/eclipse-thingweb/dart_wot/commit/40d1e011bf71758922210b02386c4624ef3a7dd5))

### Changed

- Better document fetch function ([db2da1a](https://github.com/eclipse-thingweb/dart_wot/commit/db2da1a3a6dfa37c0ad1bf5a9bc883c9c0408c6e))
- Do not export client ([749969d](https://github.com/eclipse-thingweb/dart_wot/commit/749969d63ddb615de5d3fec3dc4948d47cd9a66d))
- Move ContentSerdes to Servient ([060d846](https://github.com/eclipse-thingweb/dart_wot/commit/060d8464d247d2ea6d38eeeda6a40c69186a3979))
- Increment package version to 0.3.0 ([52a0245](https://github.com/eclipse-thingweb/dart_wot/commit/52a024542088d53db4acaf8b00b4cc18e25eb865))

### Fixed

- Fix format of LICENSE file ([df689a1](https://github.com/eclipse-thingweb/dart_wot/commit/df689a16318f9945ba0bb675ab6ee918cc5a9e40))

### Removed

- Remove unneeded import ([6a99a57](https://github.com/eclipse-thingweb/dart_wot/commit/6a99a57bf700d2371157ae67905b38bd614e84ac))
- Remove unneeded type check ([4522019](https://github.com/eclipse-thingweb/dart_wot/commit/45220197da640f78727f770c6903706f859118f0))
- Remove out of scope reference ([e0e06e9](https://github.com/eclipse-thingweb/dart_wot/commit/e0e06e920de3632aecbf6db6ad0c4b23c5e76a9a))
- Remove unneeded fetch parameter ([74e9ef2](https://github.com/eclipse-thingweb/dart_wot/commit/74e9ef287f45ba93c7646292fd9a5636876a17f7))
- Remove unused import ([e011ba7](https://github.com/eclipse-thingweb/dart_wot/commit/e011ba71e53fab380d0c577542abd37c2a2740f7))

## [0.2.0] - 2022-01-01

### Changed

- Use a shorter README title ([590475f](https://github.com/eclipse-thingweb/dart_wot/commit/590475f81179758b0593d9a6edb196242bacc55e))
- Clean up definition exports ([f64ea1c](https://github.com/eclipse-thingweb/dart_wot/commit/f64ea1c48b500a60e31d0cdd2878d1f6b13e7416))
- Improve documentation of libraries ([d5acff1](https://github.com/eclipse-thingweb/dart_wot/commit/d5acff174366506f3c28385c3948cd8c99e5cd36))
- Increment package version to 0.2.0 ([5be3987](https://github.com/eclipse-thingweb/dart_wot/commit/5be398767c74a1c7e35f4010ee9c91b9407663f8))

## [0.1.1] - 2021-12-31

### Added

- Add dependencies ([caa89d2](https://github.com/eclipse-thingweb/dart_wot/commit/caa89d28c54ea22777c2fb01856dab3c7e444f36))
- Add basic TD definitions ([f80c6a8](https://github.com/eclipse-thingweb/dart_wot/commit/f80c6a87d2c5b6237893a08f23b1a267b6eb42c4))
- Add Scripting API interfaces ([1124fbd](https://github.com/eclipse-thingweb/dart_wot/commit/1124fbd2860e462690ee3c5cf9c09d12d34d6f31))
- Add first version of core package ([04daf5f](https://github.com/eclipse-thingweb/dart_wot/commit/04daf5f5618a7ee442f9f0b790c84eeb56d1731e))
- Add basic CoAP example ([73ff074](https://github.com/eclipse-thingweb/dart_wot/commit/73ff074316e0b49874ba23e1c0b2347a420f3024))
- Add very basic tests ([2c79950](https://github.com/eclipse-thingweb/dart_wot/commit/2c799509519e5bb929577d7f828577d4c4cc99c6))

### Changed

- Add first CoAP binding version ([5dbd27c](https://github.com/eclipse-thingweb/dart_wot/commit/5dbd27c0f5535f93f1e96d554ce51cc3d4c70f51))
- Define library exports ([61e1ba9](https://github.com/eclipse-thingweb/dart_wot/commit/61e1ba9dfaeeb4cc4043748897f18635a687b04f))
- Warn if public member api docs are missing ([abaf36f](https://github.com/eclipse-thingweb/dart_wot/commit/abaf36f59cecde029029c235709fe09b4929207e))
- Move Gitlab CODEOWNERS to .gitlab folder ([bec7628](https://github.com/eclipse-thingweb/dart_wot/commit/bec7628df325a73255cddc0dffe3442c79ed2e5c))
- Expand README file ([fe6854f](https://github.com/eclipse-thingweb/dart_wot/commit/fe6854f89e9362af65b90996dca2ac194678b31f))
- Decrement version number in CHANGELOG ([c8df03a](https://github.com/eclipse-thingweb/dart_wot/commit/c8df03a3c015c12f05cc3690a06b8de746962806))
- Expand package description ([811dac1](https://github.com/eclipse-thingweb/dart_wot/commit/811dac1da6359729a3649d20e32691a708b0f896))
- Increment package version to 0.1.1 ([631d01b](https://github.com/eclipse-thingweb/dart_wot/commit/631d01b73120e6cb4680a6cc468ce672bf110239))

## [0.1.0] - 2021-12-30

### Added

- Add Gitlab CI configuration ([21b1a29](https://github.com/eclipse-thingweb/dart_wot/commit/21b1a2964cc624cde0dc310afe2ea8775f07af93))
- Add @s_edhnm5 as Gitlab CODEOWNER ([ccd66cb](https://github.com/eclipse-thingweb/dart_wot/commit/ccd66cb3ace605e46c8c39019aa38f7b2de29316))
- Add code quality reports ([5e4fa48](https://github.com/eclipse-thingweb/dart_wot/commit/5e4fa48a5c879af5a282f021d8952eb8b45c341a))
- Add dart_code_metrics rules ([fae9d79](https://github.com/eclipse-thingweb/dart_wot/commit/fae9d7933d0a27d0198ed66409bcbdffd28f1052))
- Add code intelligence ([66c97d1](https://github.com/eclipse-thingweb/dart_wot/commit/66c97d16f6994c1f3deda33fefda345aec18a0db))
- Add style and documentation linter rules ([06d2a8b](https://github.com/eclipse-thingweb/dart_wot/commit/06d2a8b4d8455396e4a7a4c3bb2d765c246147ca))
- Add usage and design rules from Effective Dart ([4a31870](https://github.com/eclipse-thingweb/dart_wot/commit/4a31870ed9484681922ae9292c2e5b247c3a001d))
- Add additional relevant linter rules ([90fb6a5](https://github.com/eclipse-thingweb/dart_wot/commit/90fb6a543ee73f2085016b0e00356457dbd1f0c8))
- Add NOTICE file for W3C code ([6aa2cd5](https://github.com/eclipse-thingweb/dart_wot/commit/6aa2cd55e48a29160b647e6951a5a6f1e412efbd))
- Add HOTELS group label to issue templates ([2fc7582](https://github.com/eclipse-thingweb/dart_wot/commit/2fc758288424b20b31f87c1f63806fb45d64d262))
- Add new LICENSE file for dual-licensing ([b5161f8](https://github.com/eclipse-thingweb/dart_wot/commit/b5161f819109482b3df72ae77668863067f3fbd6))
- Add GitHub repository to pubspec.yaml file ([c1d447e](https://github.com/eclipse-thingweb/dart_wot/commit/c1d447e52c52585bda2ed6ee6f9424e3e2830385))

### Changed

- Initial commit ([937f2e9](https://github.com/eclipse-thingweb/dart_wot/commit/937f2e96ec7f81cf61294fb1ce1af5ef32245cb6))
- Extend .gitignore ([2482fe0](https://github.com/eclipse-thingweb/dart_wot/commit/2482fe095413f04f82a3b5651967c49fa6290960))
- Implement unit test reports ([d63f3db](https://github.com/eclipse-thingweb/dart_wot/commit/d63f3db0c092d4c40d231066184b5ec6ff2bb633))
- Generate code coverage report ([cb0c83e](https://github.com/eclipse-thingweb/dart_wot/commit/cb0c83e142335e2c464b75f3d5ef1cda60ffcbe0))
- Set rules for `dart_code_metrics` plugin ([1ae925a](https://github.com/eclipse-thingweb/dart_wot/commit/1ae925a9ba7d8fca412f934b3ee5aa3a4e9a727f))
- Switch to official dart docker image ([b26729c](https://github.com/eclipse-thingweb/dart_wot/commit/b26729c92a94a51091acfceda7debd6cd41e15d0))
- Enable rules correctly ([54699be](https://github.com/eclipse-thingweb/dart_wot/commit/54699bec23d0916b977283cee63e71f376805d1f))
- Apply 1 suggestion(s) to 1 file(s) ([efefce8](https://github.com/eclipse-thingweb/dart_wot/commit/efefce8c7992e0f2c99b9684055d0bf069d76fc7))
- Rename LICENSE-MIT to LICENSE ([8992183](https://github.com/eclipse-thingweb/dart_wot/commit/8992183c098daf761a1f5b7f01ee8b9f8bf802a1))
- Change order of licenses in readme ([f356860](https://github.com/eclipse-thingweb/dart_wot/commit/f356860dde79f3518672f1c3fc177d6e9e2d3a2f))
- Rename old LICENSE to LICENSE-MIT ([b291cd5](https://github.com/eclipse-thingweb/dart_wot/commit/b291cd538e7b86f648c8a2b07e26593413688908))
- Attribute node-wot in README and LICENSE ([b3f2c28](https://github.com/eclipse-thingweb/dart_wot/commit/b3f2c28ac5d86404528c7e3dfc2e295c3c3ba814))
- Decrement version number to 0.1.0 ([9cc4191](https://github.com/eclipse-thingweb/dart_wot/commit/9cc4191bea41e5fe9dca08ae0999ef962dce1291))

### Removed

- Remove TODO from misc issue template ([f0281cf](https://github.com/eclipse-thingweb/dart_wot/commit/f0281cf91d3ab717fa18aef0576ddef5aaf9abcb))

[Unreleased]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.28.2..HEAD
[0.28.2]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.28.1..v0.28.2
[0.28.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.28.0..v0.28.1
[0.28.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.27.1..v0.28.0
[0.27.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.27.0..v0.27.1
[0.27.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.26.0..v0.27.0
[0.26.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.25.1..v0.26.0
[0.25.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.25.0..v0.25.1
[0.25.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.24.1..v0.25.0
[0.24.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.24.0..v0.24.1
[0.24.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.23.1..v0.24.0
[0.23.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.23.0..v0.23.1
[0.23.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.22.0..v0.23.0
[0.22.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.21.1..v0.22.0
[0.21.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.21.0..v0.21.1
[0.21.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.20.1..v0.21.0
[0.20.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.20.0..v0.20.1
[0.20.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.19.1..v0.20.0
[0.19.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.19.0..v0.19.1
[0.19.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.18.0..v0.19.0
[0.18.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.17.0..v0.18.0
[0.17.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.16.0..v0.17.0
[0.16.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.15.1..v0.16.0
[0.15.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.15.0..v0.15.1
[0.15.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.14.0..v0.15.0
[0.14.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.13.0..v0.14.0
[0.13.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.12.1..v0.13.0
[0.12.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.12.0..v0.12.1
[0.12.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.11.1..v0.12.0
[0.11.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.11.0..v0.11.1
[0.11.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.10.0..v0.11.0
[0.10.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.9.0..v0.10.0
[0.9.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.8.0..v0.9.0
[0.8.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.7.1..v0.8.0
[0.7.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.7.0..v0.7.1
[0.7.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.6.1..v0.7.0
[0.6.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.6.0..v0.6.1
[0.6.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.5.0..v0.6.0
[0.5.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.4.0..v0.5.0
[0.4.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.3.0..v0.4.0
[0.3.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.2.0..v0.3.0
[0.2.0]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.1.1..v0.2.0
[0.1.1]: https://github.com/eclipse-thingweb/dart_wot/compare/v0.1.0..v0.1.1
[0.1.0]: https://github.com/eclipse-thingweb/dart_wot/releases/tag/v0.1.0

<!-- generated by git-cliff -->
