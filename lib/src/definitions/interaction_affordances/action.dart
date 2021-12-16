// Copyright 2021 The NAMIB Project Developers
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.
//
// SPDX-License-Identifier: MIT OR Apache-2.0

import '../data_schema.dart';
import '../form.dart';
import 'interaction_affordance.dart';

/// Class representing an [Action] Affordance in a Thing Description.
class Action extends InteractionAffordance {
  /// The default title of this [Action].
  String? title;

  /// The default description of this [Action].
  String? description;

  /// The schema of the [input] data this [Action] accepts.
  DataSchema? input;

  /// The schema of the [output] data this [Action] produces.
  DataSchema? output;

  /// Creates a new [Action] from a [List] of [forms].
  Action(List<Form> forms) : super(forms);

  /// Creates a new [Action] from a [json] object.
  Action.fromJson(Map<String, dynamic> json) : super([]) {
    parseForms(json);
  }
}
