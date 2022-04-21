import 'package:combine/src/isolate_factory/effective_isolate_factory.dart';
import 'package:combine/src/isolate_factory/native_isolate_factory.dart'
    as native_factory;
import 'package:combine/src/isolate_factory/web_isolate_factory.dart'
    as web_factory;
import 'package:flutter_test/flutter_test.dart';

import 'combine_spawners/arguments_resend_combine_spawner.dart';
import 'combine_spawners/counter_combine_spawners.dart';

void main() {
  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  group("Test with native isolate factory", () {
    setUpAll(() {
      setTestIsolateFactory(native_factory.IsolateFactoryImpl());
    });

    commonCombineTest();
  });

  group("Test with web isolate factory", () {
    setUpAll(() {
      setTestIsolateFactory(web_factory.IsolateFactoryImpl());
    });

    commonCombineTest();
  });
}

void commonCombineTest() {
  test('Test with simple counter', () async {
    final isolate = await spawnSimpleCounterIsolate();

    isolate.messenger.send(null);
    expect(await isolate.messenger.messages.first, 1);

    isolate.messenger.send(null);
    expect(await isolate.messenger.messages.first, 2);
  });

  test('Test with complex counter', () async {
    final isolate = await spawnEventCounterIsolate();
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

  test(
    "Test method channel using counter which incremented in 'platform'",
    () async {
      final isolate = await spawnMethodChannelCounterIsolate();

      isolate.messenger.send(null);
      expect(await isolate.messenger.messages.first, 1);

      isolate.messenger.send(null);
      expect(await isolate.messenger.messages.first, 2);
      isolate.kill();
    },
  );

  test("Test method channel invoked from platform", () async {
    final isolate = await spawnComplexMethodChannelCounterIsolate();

    isolate.messenger.send(null);
    expect(await isolate.messenger.messages.first, 1);

    isolate.messenger.send(null);
    expect(await isolate.messenger.messages.first, 2);
  });

  test("Can't communicate with killed isolate", () async {
    final isolate = await spawnSimpleCounterIsolate();
    var isDone = false;

    isolate.messenger.messages.listen((event) {}, onDone: () => isDone = true);
    isolate.kill();
    // Wait when on kill stuff will be done.
    await null;

    expect(isDone, isTrue);
  });

  test('Argument is passed correctly', () async {
    const argument = CounterInfoEvent(42);
    final isolate = await spawnArgumentsResendIsolate(argument);
    expect(await isolate.messenger.messages.first, argument);
  });
}
