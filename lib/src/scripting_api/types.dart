// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../definitions/thing_description.dart';
import 'interaction_output.dart';

/// The (optional) input for an interaction.
///
/// Can be any type, although only basic types as well as streams can actually
///  be handled.
typedef InteractionInput = Object?;

/// Maps multiple [InteractionOutput]s to property names.
///
/// Will be the result of a `readmultipleproperties` or `readallproperties`
/// operation.
typedef PropertyReadMap = Map<String, InteractionOutput>;

/// Maps multiple [InteractionInput]s to property names.
///
/// Can be the input of a `writemultipleproperties` or `writeallproperties`
/// operation.
typedef PropertyWriteMap = Map<String, InteractionInput>;

/// Dictionary used for the initialization of an exposed Thing.
///
/// Represents a Partial TD as described in the
/// [WoT Architecture](https://w3c.github.io/wot-architecture/#dfn-partial-td).
typedef ExposedThingInit = Map<String, dynamic>;
