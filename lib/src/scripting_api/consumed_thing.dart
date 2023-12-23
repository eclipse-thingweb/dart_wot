// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import '../definitions/thing_description.dart';
import 'interaction_output.dart';
import 'subscription.dart';
import 'types.dart';

/// User provided callback that is given an argument of type [InteractionOutput]
/// and is used for observing Property changes and handling Event notifications.
typedef InteractionListener = void Function(InteractionOutput data);

/// User provided callback that is given an argument of type Error and is used
/// for conveying critical and non-critical errors from the Protocol Bindings to
/// applications.
typedef ErrorListener = void Function(Exception data);

/// Represents a client API to operate a Thing. Belongs to the WoT Consumer
/// conformance class.
///
/// See [WoT Scripting API Specification, Section 8][spec link].
///
/// [spec link]: https://w3c.github.io/wot-scripting-api/#the-consumedthing-interface
abstract interface class ConsumedThing {
  /// Returns the [ThingDescription] that represents the consumed Thing.
  ThingDescription get thingDescription;

  /// Reads a property with the given [propertyName].
  Future<InteractionOutput> readProperty(
    String propertyName, {
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  });

  /// Reads all properties.
  Future<PropertyReadMap> readAllProperties({
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  });

  /// Reads a number of properties with the given [propertyNames].
  Future<PropertyReadMap> readMultipleProperties(
    List<String> propertyNames, {
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  });

  /// Writes an [interactionInput] value to a property with the given
  /// [propertyName].
  Future<void> writeProperty(
    String propertyName,
    InteractionInput interactionInput, {
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  });

  /// Writes multiple values to multiple properties, as described in a
  /// [valueMap].
  Future<void> writeMultipleProperties(
    PropertyWriteMap valueMap, {
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  });

  /// Invokes an action with the given [actionName]. Accepts an optional
  /// [input].
  ///
  /// After (asynchronous )completion, it might return an [InteractionOutput].
  Future<InteractionOutput> invokeAction(
    String actionName, {
    InteractionInput input,
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  });

  /// Observes a property with the given [propertyName].
  Future<Subscription> observeProperty(
    String propertyName,
    InteractionListener listener, {
    ErrorListener? onError,
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  });

  /// Subscribes to an event with the given [eventName].
  Future<Subscription> subscribeEvent(
    String eventName,
    InteractionListener listener, {
    ErrorListener? onError,
    int? formIndex,
    Map<String, Object>? uriVariables,
    Object? data,
  });
}
