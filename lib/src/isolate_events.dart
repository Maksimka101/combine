import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

@immutable
abstract class IsolateEvent extends Equatable {
  const IsolateEvent();

  @override
  List<Object?> get props => [];
}

/// Event to invoke [MethodChannel] in main isolate.
@immutable
class InvokePlatformChannelEvent extends IsolateEvent {
  const InvokePlatformChannelEvent(this.data, this.channel, this.id);

  final ByteData? data;
  final String channel;
  final String id;

  @override
  List<Object?> get props => [data, channel, id];
}

/// Event with response from [MethodChannel]
@immutable
class PlatformChannelResponseEvent extends IsolateEvent {
  const PlatformChannelResponseEvent(this.data, this.id);

  final ByteData? data;
  final String id;

  @override
  List<Object?> get props => [data, id];
}

/// Event to invoke [MethodChannel.setMethodCallHandler] in [IsolateBloc]'s isolate.
@immutable
class InvokeMethodChannelEvent extends IsolateEvent {
  const InvokeMethodChannelEvent(this.data, this.channel, this.id);

  final ByteData? data;
  final String channel;
  final String id;

  @override
  List<Object?> get props => [data, channel, id];
}

/// Event with response from [MethodChannel.setMethodCallHandler] in [IsolateBloc]'s isolate.
@immutable
class MethodChannelResponseEvent extends IsolateEvent {
  const MethodChannelResponseEvent(this.data, this.id);

  final ByteData? data;
  final String id;

  @override
  List<Object?> get props => [data, id];
}
