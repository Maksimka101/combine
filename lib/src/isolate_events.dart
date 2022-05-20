import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

@immutable
abstract class IsolateEvent {
  const IsolateEvent();
}

/// Event to invoke [MethodChannel] in main isolate.
@immutable
class InvokePlatformChannelEvent extends IsolateEvent {
  const InvokePlatformChannelEvent(this.data, this.channel, this.id);

  final ByteData? data;
  final String channel;
  final int id;
}

/// Event with response from [MethodChannel]
@immutable
class PlatformChannelResponseEvent extends IsolateEvent {
  const PlatformChannelResponseEvent(this.data, this.id);

  final ByteData? data;
  final int id;
}

/// Event to invoke [MethodChannel.setMethodCallHandler] in [IsolateBloc]'s isolate.
@immutable
class InvokeMethodChannelEvent extends IsolateEvent {
  const InvokeMethodChannelEvent(this.data, this.channel, this.id);

  final ByteData? data;
  final String channel;
  final int id;
}

/// Event with response from [MethodChannel.setMethodCallHandler] in [IsolateBloc]'s isolate.
@immutable
class MethodChannelResponseEvent extends IsolateEvent {
  const MethodChannelResponseEvent(this.data, this.id);

  final ByteData? data;
  final int id;
}
