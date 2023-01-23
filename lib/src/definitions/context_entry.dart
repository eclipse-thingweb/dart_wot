// Copyright 2021 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:curie/curie.dart';
import 'package:meta/meta.dart';

import 'validation/validation_exception.dart';

const _validTdContextValues = [
  'https://www.w3.org/2019/wot/td/v1',
  'https://www.w3.org/2022/wot/td/v1.1',
  'http://www.w3.org/ns/td'
];

/// Class holding a [value] and an optional [key] for representing different
/// types of `@context` entries.
@immutable
class ContextEntry {
  /// Creates a new [ContextEntry].
  const ContextEntry(this.value, this.key);

  /// Parses a [List] of `@context` entries from a given [json] value.
  ///
  /// `@context` extensions are added to the provided [prefixMapping].
  /// If a given entry is the [firstEntry], it will be set in the
  /// [prefixMapping] accordingly.
  static List<ContextEntry> fromJson(
    dynamic json,
    PrefixMapping prefixMapping, {
    required bool firstEntry,
  }) {
    // TODO: Refactor
    if (json is String) {
      if (firstEntry && _validTdContextValues.contains(json)) {
        prefixMapping.defaultPrefixValue = json;
      }
      return [ContextEntry(json, null)];
    }

    if (json is Map<String, dynamic>) {
      final contextEntries = <ContextEntry>[];
      for (final contextEntry in json.entries) {
        final key = contextEntry.key;
        final value = contextEntry.value;
        if (value is String) {
          if (!key.startsWith('@') && Uri.tryParse(value) != null) {
            prefixMapping.addPrefix(key, value);
          }
          contextEntries.add(ContextEntry(value, key));
        }
      }

      return contextEntries;
    }

    throw ValidationException(
      'Excepted either a String or a Map<String, String> '
      'as @context entry, got ${json.runtimeType} instead.',
    );
  }

  /// Parses a TD `@context` from a [json] value.
  ///
  /// @context extensions are added to the provided [prefixMapping].
  static List<ContextEntry> parseContext(
    dynamic json,
    PrefixMapping prefixMapping,
  ) {
    var firstEntry = true;

    if (json is String) {
      return ContextEntry.fromJson(json, prefixMapping, firstEntry: firstEntry);
    }

    if (json is List<dynamic>) {
      final List<ContextEntry> result = [];
      for (final contextEntry in json) {
        result.addAll(
          ContextEntry.fromJson(
            contextEntry,
            prefixMapping,
            firstEntry: firstEntry,
          ),
        );
        firstEntry = false;
      }
      return result;
    }

    throw ValidationException(
      'Excepted either a single @context entry or a List of @context entries, '
      'got ${json.runtimeType} instead.',
    );
  }

  /// The [value] of this [ContextEntry].
  final String value;

  /// The [key] of this [ContextEntry]. Might be `null`.
  final String? key;

  @override
  bool operator ==(Object? other) {
    return hashCode == other.hashCode;
  }

  @override
  int get hashCode => Object.hash(value, key);
}
