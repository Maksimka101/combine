import 'package:combine/combine.dart';
import 'package:combine/src/binary_messenger_middleware/isolated_method_channel_middleware.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

late final _counterMethodChannel = MethodChannel(
  "counter",
  const StandardMethodCodec(),
  ServicesBinding.instance.defaultBinaryMessenger,
);

Future<CombineInfo> spawnSimpleCounterIsolate() {
  return Combine().spawn((context) {
    var counter = 0;
    context.messenger.messages.listen((event) {
      context.messenger.send(++counter);
    });
  });
}

Future<CombineInfo> spawnSimpleCounterIsolateInsideAnotherIsolate() {
  return Combine().spawn((context) async {
    final isolateInfo = await spawnSimpleCounterIsolate();
    context.messenger.send(null);
    context.messenger.messages.listen((msg) {
      isolateInfo.messenger.send(msg);
    });
    isolateInfo.messenger.messages.listen((msg) {
      context.messenger.send(msg);
    });
  });
}

Future<CombineInfo> spawnMethodChannelCounterIsolate() {
  var counter = 0;
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    _counterMethodChannel,
    (call) async => ++counter,
  );

  return Combine().spawn((context) {
    context.messenger.messages.listen((event) async {
      context.messenger.send(
        await _counterMethodChannel.invokeMethod("increment"),
      );
    });
  });
}

Future<CombineInfo> checkMethodChannelInIsolateIsInitialized() {
  return Combine().spawn((context) {
    try {
      // Test will not pass when they are not initialized (are null).
      IsolatedBinaryMessengerMiddleware.instance!;
      BackgroundIsolateBinaryMessenger.instance;
      context.messenger.send(true);
    } catch (e) {
      context.messenger.send(false);
    }
  });
}

Future<CombineInfo> spawnComplexMethodChannelCounterIsolate() {
  var counter = 0;
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_counterMethodChannel, (call) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
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

Future<CombineInfo> spawnEventCounterIsolate() {
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

@immutable
class CounterInfoEvent {
  const CounterInfoEvent(this.count);

  final int count;

  @override
  int get hashCode => count.hashCode;

  @override
  bool operator ==(Object other) =>
      other is CounterInfoEvent && other.count == count;
}
