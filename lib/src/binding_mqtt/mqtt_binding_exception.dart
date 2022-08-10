// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

/// An [Exception] that is thrown if an error occurs within the MQTT binding.
class MqttBindingException implements Exception {
  /// Constructor.
  MqttBindingException(this._message);

  final String _message;

  @override
  String toString() => 'MqttBindingException: $_message';
}
