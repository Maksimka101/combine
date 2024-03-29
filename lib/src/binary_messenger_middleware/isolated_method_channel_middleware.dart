import 'dart:async';
import 'dart:ui' as ui;

import 'package:combine/src/id_generator.dart/id_generator.dart';
import 'package:combine/src/isolate_events.dart';
import 'package:combine/src/isolate_messenger/internal_isolate_messenger/internal_isolate_messenger.dart';
import 'package:flutter/services.dart';

/// This class receives messages from [BinaryMessenger] and sends them to the
/// UI Isolate.
class IsolatedBinaryMessengerMiddleware extends BinaryMessenger {
  IsolatedBinaryMessengerMiddleware(this._isolateMessenger)
      : _generateId = IdGenerator();

  /// Last created and [initialize]d middleware.
  static IsolatedBinaryMessengerMiddleware? instance;

  final InternalIsolateMessenger _isolateMessenger;
  late BinaryMessenger _binaryMessenger;
  final IdGenerator _generateId;
  final _platformResponsesCompleter = <int, Completer<ByteData?>>{};

  /// Starts listening for [IsolateEvent]s from UI Isolate and sets middleware for [BinaryMessenger].
  void initialize() {
    instance = this;
    _isolateMessenger.messagesStream
        .where((event) => event is IsolateEvent)
        .cast<IsolateEvent>()
        .listen(_listenForMethodChannelEvents);
  }

  void setBinaryMessage(BinaryMessenger binaryMessenger) {
    _binaryMessenger = binaryMessenger;
  }

  void _listenForMethodChannelEvents(IsolateEvent event) {
    if (event is PlatformChannelResponseEvent) {
      _platformChannelResponse(event.id, event.data);
    } else if (event is InvokeBinaryMessengerChannelEvent) {
      _handlePlatformMessage(
        event.channel,
        event.id,
        event.data,
      );
    }
  }

  /// Handle platform messages and send them to it's [MessageChannel].
  void _handlePlatformMessage(String channel, int id, ByteData? message) {
    handlePlatformMessage(channel, message, (data) {
      _isolateMessenger.send(BinaryMessengerResponseEvent(data, id));
    });
  }

  /// Sends response from platform channel to it's message handler.
  void _platformChannelResponse(int id, ByteData? response) {
    final completer = _platformResponsesCompleter.remove(id);
    assert(
      completer != null,
      "Failed to send response from platform channel "
      "to it's message handler.",
    );
    completer?.complete(response);
  }

  @override
  Future<void> handlePlatformMessage(
    String channel,
    ByteData? data,
    ui.PlatformMessageResponseCallback? callback,
  ) async {
    ui.channelBuffers.push(channel, data, (data) {
      if (callback != null) {
        callback(data);
      }
    });
  }

  @override
  Future<ByteData?>? send(String channel, ByteData? message) {
    final completer = Completer<ByteData?>();
    final id = _generateId();
    _platformResponsesCompleter[id] = completer;
    _isolateMessenger.send(InvokePlatformChannelEvent(message, channel, id));
    return completer.future;
  }

  @override
  void setMessageHandler(String channel, MessageHandler? handler) {
    _binaryMessenger.setMessageHandler(channel, handler);
  }
}

typedef PlatformMessageHandler = void Function(
  String channel,
  ByteData? message,
  ui.PlatformMessageResponseCallback? callback,
);

typedef PlatformResponseHandler = Future<ByteData?>? Function(
  String channel,
  ByteData? message,
);
