import 'package:combine/combine.dart';
import 'package:combine/src/isolate_factory/isolate_factory.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _counterMethodChannel = MethodChannel("counter");

Future<CombineIsolate> spawnSimpleCounterIsolate(IsolateFactory factory) {
  return factory.create((context) {
    var counter = 0;
    context.messenger.messages.listen((event) {
      context.messenger.send(++counter);
    });
  });
}

Future<CombineIsolate> spawnMethodChannelCounterIsolate(
  IsolateFactory factory,
) {
  var counter = 0;
  _counterMethodChannel.setMockMethodCallHandler((call) async => ++counter);

  return factory.create((context) {
    context.messenger.messages.listen((event) async {
      context.messenger.send(
        await _counterMethodChannel.invokeMethod("increment"),
      );
    });
  });
}

Future<CombineIsolate> spawnEventCounterIsolate(IsolateFactory factory) {
  return factory.create((context) {
    var counter = 0;
    context.messenger.messages.listen((event) {
      if (event is IncrementEvent) {
        context.messenger.send(CounterInfoEvent(++counter));
      } else if (event is DecrementEvent) {
        context.messenger.send(CounterInfoEvent(--counter));
      }
    });
  });
}

class IncrementEvent {}

class DecrementEvent {}

class CounterInfoEvent extends Equatable {
  const CounterInfoEvent(this.count);

  final int count;

  @override
  List<Object?> get props => [count];
}
