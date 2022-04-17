import 'dart:async';

import 'package:combine/src/isolate_events.dart';
import 'package:combine/src/isolate_messenger/internal_isolate_messenger/internal_isolate_messenger.dart';
import 'package:combine/src/method_channel_middleware/isolated_method_channel_middleware.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

/// This class receives messages from [MethodChannel.setMessageHandler]
/// registered in [MethodChannelSetup] and sends messages received from Isolate.
class UIMethodChannelMiddleware {
  /// Creates new middleware and sets [instance].
  UIMethodChannelMiddleware(
    this._binaryMessenger,
    this._isolateMessenger,
  )   : _idGenerator = const Uuid().v4,
        _methodChannels = {};

  static UIMethodChannelMiddleware? instance;

  final BinaryMessenger _binaryMessenger;
  final Set<String> _methodChannels;
  final IdGenerator _idGenerator;
  final InternalIsolateMessenger _isolateMessenger;
  final _messageHandlersCompleter = <String, Completer<ByteData>>{};
  StreamSubscription<IsolateEvent>? _methodChannelEventsSubscription;

  /// Starts listening for [IsolateEvent]s from Isolate and sets middleware for [MethodChannel].
  void initialize() {
    instance = this;
    _bindPlatformMessageHandlers();
    _methodChannelEventsSubscription = _isolateMessenger.messagesStream
        .where((event) => event is IsolateEvent)
        .cast<IsolateEvent>()
        .listen(_listenForMethodChannelEvents);
  }

  /// Free all resources and remove middleware from [MethodChannel].
  Future<void> dispose() async {
    await _methodChannelEventsSubscription?.cancel();
    _unbindPlatformMessageHandlers();
  }

  void _listenForMethodChannelEvents(IsolateEvent event) {
    switch (event.runtimeType) {
      case InvokePlatformChannelEvent:
        final invokeEvent = event as InvokePlatformChannelEvent;
        _send(invokeEvent.channel, invokeEvent.data, invokeEvent.id);
        break;
      case MethodChannelResponseEvent:
        final responseEvent = event as MethodChannelResponseEvent;
        _methodChannelResponse(responseEvent.id, responseEvent.data);
        break;
    }
  }

  /// Send response from IsolateBloc's MessageChannel to the main
  /// Isolate's platform channel.
  void _methodChannelResponse(String id, ByteData? response) {
    final completer = _messageHandlersCompleter.remove(id);
    if (completer == null) {
      throw _UnexpectedMethodChannelResponse();
    } else {
      completer.complete(response);
    }
  }

  /// Send event to the platform and send response to the IsolateBloc's Isolate.
  Future<void> _send(String channel, ByteData? message, String id) async {
    if (!_methodChannels.contains(channel)) {
      _addPlatformMessageHandler(channel);
    }

    final response = await _binaryMessenger.send(channel, message);
    _isolateMessenger.send(PlatformChannelResponseEvent(response, id));
  }

  void _bindPlatformMessageHandlers() {
    _methodChannels.forEach(_bindPlatformMessageHandler);
  }

  void _addPlatformMessageHandler(String channel) {
    _methodChannels.add(channel);
    _bindPlatformMessageHandler(channel);
  }

  void _bindPlatformMessageHandler(String channel) {
    _binaryMessenger.setMessageHandler(channel, (message) {
      final completer = Completer<ByteData>();
      final id = _idGenerator();
      _messageHandlersCompleter[id] = completer;
      _isolateMessenger.send(InvokeMethodChannelEvent(message, channel, id));

      return completer.future;
    });
  }

  void _unbindPlatformMessageHandlers() {
    for (final channel in _methodChannels) {
      _binaryMessenger.setMessageHandler(channel, null);
    }
  }
}

class _UnexpectedMethodChannelResponse implements Exception {
  @override
  String toString() {
    return "Failed to send response from IsolateBloc's MessageChannel "
        "to the main Isolate's platform channel.\n"
        "This is internal error";
  }
}
