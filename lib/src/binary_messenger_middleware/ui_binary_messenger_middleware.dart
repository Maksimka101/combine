import 'dart:async';

import 'package:combine/src/id_generator.dart/id_generator.dart';
import 'package:combine/src/isolate_events.dart';
import 'package:combine/src/isolate_messenger/internal_isolate_messenger/internal_isolate_messenger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// This class receives messages from the [BinaryMessenger.setMessageHandler]
/// and sends messages received from Isolate.
class UIBinaryMessengerMiddleware {
  UIBinaryMessengerMiddleware(
    this._binaryMessenger,
    this._isolateMessenger,
  )   : _idGenerator = IdGenerator(),
        _channelsForInterception = {};

  final BinaryMessenger _binaryMessenger;
  final Set<String> _channelsForInterception;
  final IdGenerator _idGenerator;
  final InternalIsolateMessenger _isolateMessenger;
  final _messageHandlersCompleter = <int, Completer<ByteData>>{};
  StreamSubscription<IsolateEvent>? _binaryMessengerEventsSubscription;

  @visibleForTesting
  static final uiBinaryMessengerMiddleware = <UIBinaryMessengerMiddleware>[];

  /// Starts listening for [IsolateEvent]s from Isolate and sets middleware for [BinaryMessenger].
  void initialize() {
    assert(() {
      uiBinaryMessengerMiddleware.add(this);
      return true;
    }());
    _bindPlatformMessageHandlers();
    _binaryMessengerEventsSubscription = _isolateMessenger.messagesStream
        .where((event) => event is IsolateEvent)
        .cast<IsolateEvent>()
        .listen(_listenForMethodChannelEvents);
  }

  /// Free all resources and remove middleware from [BinaryMessenger].
  Future<void> dispose() async {
    assert(() {
      uiBinaryMessengerMiddleware.remove(this);
      return true;
    }());
    await _binaryMessengerEventsSubscription?.cancel();
    _unbindPlatformMessageHandlers();
  }

  void _listenForMethodChannelEvents(IsolateEvent event) {
    if (event is BinaryMessengerResponseEvent) {
      _methodChannelResponse(event.id, event.data);
    } else if (event is InvokePlatformChannelEvent) {
      _send(event.channel, event.data, event.id);
    }
  }

  /// Send response from IsolateBloc's MessageChannel to the main
  /// Isolate's platform channel.
  void _methodChannelResponse(int id, ByteData? response) {
    final completer = _messageHandlersCompleter.remove(id);
    assert(
      completer != null,
      "Failed to send response from Isolate MessageChannel "
      "to the main Isolate's platform channel.\n",
    );
    completer?.complete(response);
  }

  /// Send event to the platform and send response to the IsolateBloc's Isolate.
  Future<void> _send(String channel, ByteData? message, int id) async {
    if (!_channelsForInterception.contains(channel)) {
      _addPlatformMessageHandler(channel);
    }

    final response = await _binaryMessenger.send(channel, message);
    _isolateMessenger.send(PlatformChannelResponseEvent(response, id));
  }

  void _bindPlatformMessageHandlers() {
    _channelsForInterception.forEach(_bindPlatformMessageHandler);
  }

  void _addPlatformMessageHandler(String channel) {
    _channelsForInterception.add(channel);
    _bindPlatformMessageHandler(channel);
  }

  void _bindPlatformMessageHandler(String channel) {
    _binaryMessenger.setMessageHandler(channel, (message) {
      final completer = Completer<ByteData>();
      final id = _idGenerator();
      _messageHandlersCompleter[id] = completer;
      _isolateMessenger.send(
        InvokeBinaryMessengerChannelEvent(message, channel, id),
      );

      return completer.future;
    });
  }

  void _unbindPlatformMessageHandlers() {
    for (final channel in _channelsForInterception) {
      _binaryMessenger.setMessageHandler(channel, null);
    }
  }
}
