// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "../form.dart";
import "../link.dart";
import "serializable.dart";

/// Extension that provides JSON serialization for [List]s of [Link]s.
extension SerializableList on List<Serializable> {
  /// Converts this [List] of [Serializable] elements to JSON.
  List<dynamic> toJson() =>
      map((listItem) => listItem.toJson()).toList(growable: false);
}

/// Extension that provides JSON serialization for [List]s of [Form]s.
extension SerializableMap on Map<String, Serializable> {
  /// Converts this [Map] of [Serializable] key-value pairs to JSON.
  Map<String, dynamic> toJson() =>
      map((key, value) => MapEntry(key, value.toJson()));
}

/// Extension that provides JSON serialization for [List]s of [Uri]s.
extension UriListToJsonExtension on List<Uri> {
  /// Converts this [List] of [Uri]s to JSON.
  List<String> toJson() => map((uri) => uri.toString()).toList(growable: false);
}
