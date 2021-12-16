// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import '../form.dart';

/// Base class for Interaction Affordances (Properties, Actions, and Events).
abstract class InteractionAffordance {
  /// The basic [forms] which can be used for interacting with this resource.
  List<Form> forms;

  /// A list of [forms] augmented with additional information.
  ///
  /// This information includes base addresses and security definitions.
  List<Form> augmentedForms = [];

  /// Parses [forms] represented by a [json] object.
  void parseForms(Map<String, dynamic> json) {
    for (final formJson in json["forms"]) {
      if (formJson is Map<String, dynamic>) {
        forms.add(Form.fromJson(formJson));
      }
    }
  }

  /// Creates a new [InteractionAffordance]. Accepts a [List] of [forms].
  InteractionAffordance(this.forms);
}
