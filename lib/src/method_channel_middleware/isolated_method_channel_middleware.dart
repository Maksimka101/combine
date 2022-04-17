import 'dart:async';
import 'dart:ui' as ui;

import 'package:combine/src/isolate_events.dart';
import 'package:combine/src/isolate_messenger/internal_isolate_messenger/internal_isolate_messenger.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

/// This class receives messages from [MethodChannel] and sends them to the
/// UI Isolate.
class IsolatedMethodChannelMiddleware extends BinaryMessenger {
  /// Creates new middleware and sets [instance].
  IsolatedMethodChannelMiddleware(this._isolateMessenger)
      : _generateId = const Uuid().v4;

  /// Last created and [initialize]d middleware.
  static IsolatedMethodChannelMiddleware? instance;

  final InternalIsolateMessenger _isolateMessenger;
  late BinaryMessenger _binaryMessenger;
  final IdGenerator _generateId;
  final _platformResponsesCompleter = <String, Completer<ByteData?>>{};
  StreamSubscription<IsolateEvent>? _methodChannelEventsSubscription;

  /// Starts listening for [MethodChannelEvent]s from UI Isolate and sets middleware for [MethodChannel].
  void initialize() {
    instance = this;
    _methodChannelEventsSubscription = _isolateMessenger.messagesStream
        .where((event) => event is IsolateEvent)
        .cast<IsolateEvent>()
        .listen(_listenForMethodChannelEvents);
  }

  /// Free all resources and remove middleware from [MethodChannel]
  Future<void> dispose() async {
    await _methodChannelEventsSubscription?.cancel();
  }
  
  void setBinaryMessage(BinaryMessenger binaryMessenger) {
    _binaryMessenger = binaryMessenger;
  }

  void _listenForMethodChannelEvents(IsolateEvent event) {
    switch (event.runtimeType) {
      case PlatformChannelResponseEvent:
        final responseEvent = event as PlatformChannelResponseEvent;
        _platformChannelResponse(responseEvent.id, responseEvent.data);
        break;
      case InvokeMethodChannelEvent:
        final invokeEvent = event as InvokeMethodChannelEvent;
        _handlePlatformMessage(
          invokeEvent.channel,
          invokeEvent.id,
          invokeEvent.data,
        );
        break;
    }
  }

  /// Handle platform messages and send them to it's [MessageChannel].
  void _handlePlatformMessage(String channel, String id, ByteData? message) {
    handlePlatformMessage(channel, message, (data) {
      _isolateMessenger.send(MethodChannelResponseEvent(data, id));
    });
  }

  /// Sends response from platform channel to it's message handler.
  void _platformChannelResponse(String id, ByteData? response) {
    final completer = _platformResponsesCompleter.remove(id);
    if (completer == null) {
      throw _UnexpectedPlatformChannelResponse();
    } else {
      completer.complete(response);
    }
  }

  @override
  Future<void> handlePlatformMessage(
    String channel,
    ByteData? data,
    ui.PlatformMessageResponseCallback? callback,
  ) async {
    await _binaryMessenger.handlePlatformMessage(channel, data, callback);
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

class _UnexpectedPlatformChannelResponse implements Exception {
  @override
  String toString() {
    return "Failed to send response from platform channel "
        "to it's message handler.\nThis is internal error";
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

typedef IdGenerator = String Function();
