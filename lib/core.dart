// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

/// Core implementation providing Scripting API implementations, interfaces
/// for protocol bindings, and the `Servient` class which provides the WoT
/// runtime used for consuming, exposing, and discovering Things.
library core;

// TODO(JKRhb): Reorganize top-level core package into smaller packages.
export "src/core/definitions.dart";
export "src/core/exceptions.dart";
export "src/core/extensions.dart";
export "src/core/implementation.dart";
export "src/core/protocol_interfaces.dart";
export "src/core/scripting_api.dart";
