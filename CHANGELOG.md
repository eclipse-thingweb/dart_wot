## 0.24.0

- feat: implement new CoAP vocabulary terms
- chore: move node-wot license to a separate file
- style: fix formatting of mocked classes
- chore(form): address linting issue

# 0.23.1

- chore: update dependencies

# 0.23.0

- fix: improved multicast discovery with CoRE Link-Format

# 0.22.1

- fix(definitions): added missing `writeallproperties` operation

# 0.22.0

Applied an extensive rework to the `DataSchema` class, added missing TD fields,
and improved the support for additional fields and `@context` extensions via
JSON-LD.

# 0.21.1

- fix: correctly parse String @context entries

# 0.21.0

## Fixes

- fix(coap_client): correctly set URI path for discovery
- fix(coap_client): set accept to application/link-format for CoRE Link Format discovery
- fix(binding-coap): improve reponse error handling

## New or Updated Features

- feat: adjust CoAP binding to new library API
- feat: add Codec for CoRE Link Format
- feat: add missing contentCoding field to form
- feat(binding-coap): add ACE-OAuth support
- feat: add first version of MQTT binding
- feat: improve ThingDescriptionValidationException
- feat!: allow passing invalid credentials to security callbacks
- feat: add support for CoRE RD discovery
- feat: add missing data schema fields

## Miscellaneous

Various refactorings, updated README file.

# 0.20.1

- Refactored Direct CoAP Discovery internally and updated example
- Fixed a bug that occurred when an affordance output contains zero bytes
- Fixed a bug that prevented the correct setting of a CoAP Discovery URL
- Set the correct Content-Format for CoAP Discovery with CoRE Link Format

# 0.20.0

- feat: add data model for AutoSecurityScheme
- refactor: refactor HttpRequestMethod as enhanced enum
- feat(binding-http): rework security implementation, add security bootstrapping
  for discovery
- feat: add example for basic and auto security

# 0.19.2

- fix: temporarily set `coap` version to 4.1.0

# 0.19.1

- fix: prevent CoRE Web Links from being fetched twice

# 0.19.0

- Breaking: Set direct as default Discovery method
- Made linting config even stricter

# 0.18.0

- Added support for parsing of a number of missing TD fields
- Replaced a number of Errors with Exceptions to make library more stable
- Made various refactorings, applying a stricter linting config

# 0.17.0

- Added JSON Schema Validation for TDs
- Added support for basic CoRE Resource Discovery

## 0.16.0

### New/Updated Features

- Reworked credentials system (now uses a callback-based approach)
- Reworked the API for direct discovery via CoAP and HTTP
- Performed various refactorings

### Fixes

- fixed subscription implementation for CoAP

## 0.15.1

- Added the new CoAP Binding-Template vocabulary to `complex_example.dart`

## 0.15.0

- Added CURIE expansion for additional TD fields
- Added support for new CoAP Binding-Template
- Added experimental CoAPS support

## 0.14.0

- Fixed constructor of `ThingFilter` class and aligned it with Scripting API

## 0.13.0

- Refactored internal use of credentials
- Various smaller refactorings
- Added internal clean up methods
- Fixed exposed ConsumedThing interface
- Improved test framework

## 0.12.1

- Updated examples

## 0.12.0

- Added support for global URI Template variables
- Added JSON Schema validation to the Content Serializer/Deserializer

## 0.11.1

- Updated example in README.md

## 0.11.0

- Added support for URI template variables
- Updated dependencies (`cbor` and `coap`)
- Addressed linting issues

## 0.10.0

- HTTP-Binding: Added support for Digest and Bearer Security
- Improved Documentation

## 0.9.0

- Fixed OAuth2 SecurityScheme and its documentation
- Refactored ConsumedThing class
- Reworked subscribeResource API
- Set default contentType of Forms to application/json

## 0.8.0

- feat(discovery)!: re-align discovery API with current Scripting API specification

## 0.7.1

- feat: add missing OAuth2Credentials class

## 0.7.0

- feat: let TD parse links field
- docs: improve documentation
- feat!: rework API for Credentials, parse all SecuritySchemes
- feat: add support for basic Credentials to HTTP Client

## 0.6.1

- feat: parse titles and descriptions at Thing level

## 0.6.0

- Package republished under 3-Clause BSD license

## 0.5.0

- feat: parse affordance title(s) and description(s) of interaction affordances
- feat!: let Client Factories support multiple schemes
- fix: properly parse `op` field in Forms, improve Form augmentation
- feat(protocol_client)!: remove unneeded unsubscribeResource method
- feat(core)!: add subscription op types
- feat(core): implement subscription interfaces
- feat(scripting_api)!: clean up Subscription interface
- feat(scripting_api): add findUnsubscribeForm helper
- feat(definitions): add DataSchema fields to Event class
- feat(binding_coap): implement subscription API
- feat(binding_http): adjust according to subscription API
- feat: implement readmultipleproperties, readallproperties, and writemultipleproperties operations
- fix: replace generic with concrete Exceptions
- feat: add property observation to example file
- docs(core): fix doc comment of client factory
- feat(scripting_api): turn ThingFilter into concrete class
- feat!: implement basic Discovery API version
- feat: update example with Discovery features

## 0.4.0

- Refactored and cleaned up CoAP package
- Added first version of a basic HTTP binding (only client support yet)

## 0.3.0

- chore(binding_coap): remove unneeded import
- fix(helpers): remove unneeded fetch parameter
- docs(helpers): better document fetch function
- refactor(helpers): remove unused import
- refactor(binding-coap): do not export client
- refactor(core): move ContentSerdes to Servient
- chore: fix format of LICENSE file

## 0.2.0

- docs: use a shorter README title
- refactor: clean up definition exports
- docs: improve documentation of libraries

## 0.1.1

- docs: expand package description

## 0.1.0

- Initial version.
