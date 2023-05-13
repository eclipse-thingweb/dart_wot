// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:meta/meta.dart';

/// Holds the interaction options that need to be exposed for application
/// scripts according to the Thing Description.
///
/// See [WoT Scripting API Specification, Section 8.12][spec link].
///
/// [spec link]: https://w3c.github.io/wot-scripting-api/#the-interactionoptions-dictionary
@immutable
final class InteractionOptions {
  /// Constructor
  const InteractionOptions({this.formIndex, this.uriVariables, this.data});

  /// Represents an application hint for which Form definition should be used
  /// for the given interaction.
  final int? formIndex;

  /// Represents the URI template variables to be used with the interaction.
  final Map<String, Object>? uriVariables;

  /// Represents additional opaque data that needs to be passed to the
  /// interaction.
  final Object? data;
}
