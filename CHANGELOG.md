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
