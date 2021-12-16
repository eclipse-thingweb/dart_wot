// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

/// Holds the interaction options that need to be exposed for application
/// scripts according to the Thing Description.
///
/// See [WoT Scripting API Specification, Section 8.12][spec link].
///
/// [spec link]: https://w3c.github.io/wot-scripting-api/#the-interactionoptions-dictionary
class InteractionOptions {
  /// Represents an application hint for which Form definition should be used
  /// for the given interaction.
  int? formIndex;

  /// Represents the URI template variables to be used with the interaction.
  Object? uriVariables;

  /// Represents additional opaque data that needs to be passed to the
  /// interaction.
  Object? data;
}
