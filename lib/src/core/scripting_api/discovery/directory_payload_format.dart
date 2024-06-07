// Copyright 2024 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

/// Enumeration for specifying the value of the `format` query parameter when
/// using the `exploreDirectory` discovery method.
///
/// See [section 7.3.2.1.5] of the [WoT Discovery] specification for more
/// information.
///
/// [WoT Discovery]: https://www.w3.org/TR/2023/REC-wot-discovery-20231205
/// [section 7.3.2.1.5]: https://www.w3.org/TR/2023/REC-wot-discovery-20231205/#exploration-directory-api-things-listing
enum DirectoryPayloadFormat {
  /// Indicates that an array of Thing Descriptions should be returned.
  ///
  /// This is the default value.
  array,

  /// Indicates that an collection of Thing Descriptions should be returned.
  collection,
  ;

  @override
  String toString() {
    switch (this) {
      case array:
        return "array";
      case collection:
        return "collection";
    }
  }
}
