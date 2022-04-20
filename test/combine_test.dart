import 'package:combine/src/isolate_factory/isolate_factory.dart';
import 'package:combine/src/isolate_factory/native_isolate_factory.dart'
    as native_factory;
import 'package:combine/src/isolate_factory/web_isolate_factory.dart'
    as web_factory;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'combine_spawners/counter_combine_spawners.dart';

const _testMethodChannel = MethodChannel("test");

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    _testMethodChannel.setMockMethodCallHandler((call) async => "Result");
  });

  commonCombineTest(
    "Test with native isolate factory",
    native_factory.IsolateFactoryImpl(),
  );

  commonCombineTest(
    "Test with web isolate factory",
    web_factory.IsolateFactoryImpl(),
  );
}

void commonCombineTest(String testGroupName, IsolateFactory isolateFactory) {
  test('Test with simple counter', () async {
    final isolate = await spawnSimpleCounterIsolate(isolateFactory);

    isolate.messenger.send(null);
    expect(await isolate.messenger.messages.first, 1);

    isolate.messenger.send(null);
    expect(await isolate.messenger.messages.first, 2);
  });

  test('Test with complex counter', () async {
    final isolate = await spawnEventCounterIsolate(isolateFactory);
    isolate.messenger.send(IncrementEvent());

    expect(await isolate.messenger.messages.first, const CounterInfoEvent(1));

    isolate.messenger.send(IncrementEvent());
    expect(await isolate.messenger.messages.first, const CounterInfoEvent(2));

    isolate.messenger.send(null);
    isolate.messenger.send(DecrementEvent());
    expect(await isolate.messenger.messages.first, const CounterInfoEvent(1));

    isolate.messenger.send(DecrementEvent());
    expect(await isolate.messenger.messages.first, const CounterInfoEvent(0));
  });

  test('Test with counter throw method channel', () async {
    final isolate = await spawnMethodChannelCounterIsolate(isolateFactory);

    isolate.messenger.send(null);
    expect(await isolate.messenger.messages.first, 1);

    isolate.messenger.send(null);
    expect(await isolate.messenger.messages.first, 2);
  });

  test("Can't communicate with killed isolate", () async {
    final isolate = await spawnSimpleCounterIsolate(isolateFactory);
    var isDone = false;

    isolate.messenger.messages.listen((event) {}, onDone: () => isDone = true);
    isolate.kill();
    // Wait when on kill stuff will be done.
    await null;

    expect(isDone, isTrue);
  });
}
