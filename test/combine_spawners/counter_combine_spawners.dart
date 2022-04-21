import 'package:combine/combine.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _counterMethodChannel = MethodChannel("counter");

Future<CombineIsolate> spawnSimpleCounterIsolate() {
  return Combine().spawn((context) {
    var counter = 0;
    context.messenger.messages.listen((event) {
      context.messenger.send(++counter);
    });
  });
}

Future<CombineIsolate> spawnMethodChannelCounterIsolate() {
  var counter = 0;
  _counterMethodChannel.setMockMethodCallHandler((call) async => ++counter);

  return Combine().spawn((context) {
    context.messenger.messages.listen((event) async {
      context.messenger.send(
        await _counterMethodChannel.invokeMethod("increment"),
      );
    });
  });
}

Future<CombineIsolate> spawnComplexMethodChannelCounterIsolate() {
  var counter = 0;
  _counterMethodChannel.setMockMethodCallHandler((call) {
    _counterMethodChannel.binaryMessenger.handlePlatformMessage(
      "counter",
      const StandardMethodCodec().encodeMethodCall(
        MethodCall("counter", ++counter),
      ),
      (data) {},
    );

    return null;
  });

  return Combine().spawn((context) {
    _counterMethodChannel.setMethodCallHandler((call) async {
      context.messenger.send(call.arguments);
    });

    context.messenger.messages.listen((event) {
      _counterMethodChannel.invokeMethod("increment");
    });
  });
}

Future<CombineIsolate> spawnEventCounterIsolate() {
  return Combine().spawn((context) {
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
