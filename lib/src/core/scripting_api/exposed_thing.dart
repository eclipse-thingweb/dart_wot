// Copyright 2021 Contributors to the Eclipse Foundation. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import "package:meta/meta.dart";

import "../definitions.dart";
import "interaction_input.dart";
import "interaction_output.dart";

/// A function that is called when an external request for reading a Property is
/// received and defines what to do with such requests.
typedef PropertyReadHandler = Future<InteractionInput> Function({
  int? formIndex,
  Map<String, Object>? uriVariables,
  Object? data,
});

/// A function that is called when an external request for writing a Property is
///  received and defines what to do with such requests.
typedef PropertyWriteHandler = Future<void> Function(
  InteractionOutput value, {
  int? formIndex,
  Map<String, Object>? uriVariables,
  Object? data,
});

/// A function that is called when an external request for invoking an Action
/// is received and defines what to do with such requests.
typedef ActionHandler = Future<InteractionInput> Function(
  InteractionOutput params, {
  int? formIndex,
  Map<String, Object>? uriVariables,
  Object? data,
});

/// A function that is called when an external request for subscribing to an
/// Event is received and defines what to do with such requests.
typedef EventSubscriptionHandler = Future<void> Function({
  int? formIndex,
  Map<String, Object>? uriVariables,
  Object? data,
});

/// A function that is called when an associated Event is triggered and provides
/// the data to be sent with the Event to subscribers.
typedef EventListenerHandler = Future<InteractionInput> Function();

/// The ExposedThing interface is the server API to operate the Thing that
/// allows defining request handlers, Property, Action, and Event interactions.
///
/// See [WoT Scripting API Specification, Section 9][spec link].
///
/// [spec link]: https://w3c.github.io/wot-scripting-api/#the-exposedthing-interface
abstract interface class ExposedThing {
  /// The [ThingDescription] that represents this [ExposedThing].
  ThingDescription get thingDescription;

  /// Starts exposing the Thing.
  Future<void> expose();

  /// Destroys the [ExposedThing].
  Future<void> destroy();

  /// Assigns a [handler] function to a property with a given [name].
  ///
  /// If the property is being read, the [handler] function will be called to
  /// handle the interaction.
  void setPropertyReadHandler(String name, PropertyReadHandler handler);

  /// Assigns a [handler] function to a property with a given [name].
  ///
  /// If the property is being written to, the [handler] function will be called
  /// to handle the interaction.
  void setPropertyWriteHandler(String name, PropertyWriteHandler handler);

  /// Assigns a [handler] function to a property with a given [name].
  ///
  /// If the property is being observed, the [handler] function will be called
  /// to handle the interaction.
  void setPropertyObserveHandler(String name, PropertyReadHandler handler);

  /// Assigns a [handler] function to a property with a given [name].
  ///
  /// If the observation of a property is cancelled, the [handler] function will
  ///  be called to handle the interaction.
  void setPropertyUnobserveHandler(String name, PropertyReadHandler handler);

  /// Informs all subscribers about the change of the property with the given
  /// [name].
  @experimental
  Future<void> emitPropertyChange(
    String name, [
    String contentType = "application/json",
  ]);

  /// Assigns a [handler] function to an action with a given [name].
  ///
  /// If the action is invoked, the [handler] function will be called to handle
  /// the interaction.
  void setActionHandler(String name, ActionHandler handler);

  /// Assigns a [handler] function to an event with a given [name].
  ///
  /// If the event is subscribed to, the [handler] function will be called
  /// to handle the interaction.
  void setEventSubscribeHandler(String name, EventSubscriptionHandler handler);

  /// Assigns a [handler] function to an event with a given [name].
  ///
  /// If the event is unsubscribed, the [handler] function will be called
  /// to handle the interaction.
  void setEventUnsubscribeHandler(
    String name,
    EventSubscriptionHandler handler,
  );

  /// Informs all subscribers of an Event with the given [name] that it has
  /// occurred.
  ///
  /// You can provide (optional) input [data] that is emitted with the event.
  @experimental
  Future<void> emitEvent(
    String name,
    InteractionInput data, [
    String contentType = "application/json",
  ]);
}
