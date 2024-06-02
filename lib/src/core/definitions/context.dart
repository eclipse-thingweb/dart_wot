// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:collection/collection.dart";
import "package:curie/curie.dart";
import "package:meta/meta.dart";

const _tdVersion10ContextUrl = "https://www.w3.org/2019/wot/td/v1";
const _tdVersion11ContextUrl = "https://www.w3.org/2022/wot/td/v1.1";

/// Represents the JSON-LD `@context` of a Thing Description or Thing Model.
@immutable
final class Context {
  /// Creates a new context from a list of [contextEntries].
  Context(this.contextEntries)
      : prefixMapping = _createPrefixMapping(contextEntries);

  /// Determines the default prefix URL via the procedure described in
  /// [section 5.3.1.1] of the Thing Description 1.1 specification.
  ///
  /// [section 5.3.1.1]: https://www.w3.org/TR/wot-thing-description11/#thing
  static String _determineDefaultPrefix(
    List<ContextEntry> contextEntries,
  ) {
    final firstContextEntry = contextEntries.firstOrNull;

    if (firstContextEntry is! SingleContextEntry) {
      throw const FormatException("Missing TD context URL.");
    }

    final firstContextValue = firstContextEntry.value;

    if (![_tdVersion10ContextUrl, _tdVersion11ContextUrl]
        .contains(firstContextValue)) {
      throw FormatException(
        "Encountered invalid TD context URL $firstContextEntry",
      );
    }

    final String? secondContextValue;

    final secondContextEntry = contextEntries.elementAtOrNull(1);
    if (secondContextEntry is SingleContextEntry) {
      secondContextValue = secondContextEntry.value;
    } else {
      secondContextValue = null;
    }

    if (firstContextValue == _tdVersion10ContextUrl &&
        secondContextValue == _tdVersion11ContextUrl) {
      return _tdVersion11ContextUrl;
    }

    return firstContextValue;
  }

  static PrefixMapping _createPrefixMapping(
    List<ContextEntry> contextEntries,
  ) {
    final defaultPrefixValue = _determineDefaultPrefix(contextEntries);
    final prefixMapping = PrefixMapping(defaultPrefixValue: defaultPrefixValue);

    contextEntries
        .whereType<UriMapContextEntry>()
        .where((contextEntry) => !contextEntry.key.startsWith("@"))
        .forEach(
          (contextEntry) =>
              prefixMapping.addPrefix(contextEntry.key, contextEntry.value),
        );

    return prefixMapping;
  }

  /// List of [ContextEntry] elements in this `@context` definition.
  ///
  /// These elements can either be [SingleContextEntry]s (that contain a single
  /// URI value) or [MapContextEntry]s (that contain key-value pairs).
  final List<ContextEntry> contextEntries;

  /// Used to map context extension prefixes within the `@context` to URIs.
  final PrefixMapping prefixMapping;

  /// Determines the default language for this `@context` if defined.
  String? get defaultLanguageCode => contextEntries
      .whereType<MapContextEntry>()
      .where((contextEntry) => contextEntry.key == "@language")
      .firstOrNull
      ?.value;

  /// Allows for directly accessing this [Context]'s [contextEntries] by
  /// [index].
  ContextEntry operator [](int index) {
    return contextEntries[index];
  }

  @override
  bool operator ==(Object other) {
    if (other is! Context) {
      return false;
    }

    for (final contextEntryPair
        in IterableZip([contextEntries, other.contextEntries])) {
      if (contextEntryPair[0] != contextEntryPair[1]) {
        return false;
      }
    }

    return true;
  }

  @override
  int get hashCode => Object.hashAll(contextEntries);
}

/// Base class for `@context` entries.
@immutable
sealed class ContextEntry {
  const ContextEntry();

  /// The key of this `@context` entry.
  ///
  /// Not defined for entries that are not part of a map, i.e. the
  /// [SingleContextEntry] class.
  String? get key;

  /// The value of this `@context` entry.
  String get value;
}

/// Represents a `@context` entry that contains a [uri] as its [value] and has
/// no [key] defined.
final class SingleContextEntry extends ContextEntry {
  /// Creates a new [SingleContextEntry] from a [uri].
  const SingleContextEntry(this.uri);

  /// Creates a new [SingleContextEntry] from a [string] that represents a URI.
  ///
  /// If the [string] should not be a valid URI, this factory constructor will
  /// throw a [FormatException].
  factory SingleContextEntry.fromString(String string) {
    final parsedUri = Uri.tryParse(string);

    if (parsedUri == null) {
      throw FormatException("Encountered invalid URI $string");
    }

    return SingleContextEntry(parsedUri);
  }

  @override
  String? get key => null;

  /// The [value] of this `@context` entry as a [Uri] object.
  final Uri uri;

  /// The [String] representation of this `@context` entry's value.
  @override
  String get value => uri.toString();

  @override
  bool operator ==(Object other) {
    if (other is! SingleContextEntry) {
      return false;
    }

    return value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}

/// Super class of `@context` entries that are [key]-[value] pairs.
sealed class MapContextEntry extends ContextEntry {
  const MapContextEntry(this.key);

  /// The key of this `@context` entry.
  @override
  final String key;

  @override
  bool operator ==(Object other) {
    if (other is! MapContextEntry) {
      return false;
    }

    return key == other.key && value == other.value;
  }

  @override
  int get hashCode => Object.hash(key, value);
}

/// Key-value `@context` entry that contains a [uri] as its [value].
final class UriMapContextEntry extends MapContextEntry {
  /// Creates a new [UriMapContextEntry] from a [key] and a [uri].
  const UriMapContextEntry(super.key, this.uri);

  /// The URI that the [key] of this `@context` entry points to.
  final Uri uri;

  @override
  String get value => uri.toString();
}

/// Key-value `@context` entry that contains a non-URI string as its [value].
final class StringMapContextEntry extends MapContextEntry {
  /// Creates a new [UriMapContextEntry] from a [key] and a plain string
  /// [value].
  const StringMapContextEntry(super.key, this.value);

  @override
  final String value;
}
