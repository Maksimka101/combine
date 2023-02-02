import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

@immutable
abstract class IsolateEvent {
  const IsolateEvent();
}

/// Event to invoke [BinaryMessenger] in main isolate.
@immutable
class InvokePlatformChannelEvent extends IsolateEvent {
  const InvokePlatformChannelEvent(this.data, this.channel, this.id);

  final ByteData? data;
  final String channel;
  final int id;
}

/// Event with response from [BinaryMessenger].
@immutable
class PlatformChannelResponseEvent extends IsolateEvent {
  const PlatformChannelResponseEvent(this.data, this.id);

  final ByteData? data;
  final int id;
}

/// Event to invoke [BinaryMessenger.setMessageHandler] in isolate.
@immutable
class InvokeBinaryMessengerChannelEvent extends IsolateEvent {
  const InvokeBinaryMessengerChannelEvent(this.data, this.channel, this.id);

  final ByteData? data;
  final String channel;
  final int id;
}

/// Event with response from [BinaryMessenger.setMessageHandler] in isolate.
@immutable
class BinaryMessengerResponseEvent extends IsolateEvent {
  const BinaryMessengerResponseEvent(this.data, this.id);

  final ByteData? data;
  final int id;
}
