import 'package:combine/src/isolate_factory/effective_isolate_factory.dart';
import 'package:combine/src/isolate_factory/native_isolate_factory.dart';
import 'package:combine/src/isolate_factory/web_isolate_factory.dart';
import 'package:combine/src/isolate_messenger/internal_isolate_messenger/internal_isolate_messenger.dart';
import 'package:combine/src/method_channel_middleware/ui_method_channel_middleware.dart';
import 'package:flutter_test/flutter_test.dart';

import 'combine_spawners/arguments_resend_combine_spawner.dart';
import 'combine_spawners/counter_combine_spawners.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group("Test with native isolate factory", () {
    setUpAll(() {
      setTestIsolateFactory(NativeIsolateFactory());
    });

    commonCombineTest();

    test(
      'Method channel middleware and Background isolate binary messenger are initialized',
      () async {
        final combineInfo = await checkMethodChannelInIsolateIsInitialized();

        expect(UIMethodChannelMiddleware.instance, isNotNull);
        final isolateIsInitialized = await combineInfo.messenger.messages.first;
        expect(isolateIsInitialized, isTrue);

        combineInfo.isolate.kill();
      },
    );
  });

  group("Test with web isolate factory", () {
    setUpAll(() {
      setTestIsolateFactory(WebIsolateFactory());
    });

    commonCombineTest();
  });

  test(
    "'effectiveIsolateFactory' returns native factory because tests are run in native env",
    () async {
      cleanTestIsolateFactory();
      expect(
        effectiveIsolateFactory.runtimeType,
        NativeIsolateFactory,
      );
    },
  );
}

void commonCombineTest() {
  test('Test with simple counter', () async {
    final combineInfo = await spawnSimpleCounterIsolate();

    combineInfo.messenger.send(null);
    expect(await combineInfo.messenger.messages.first, 1);

    combineInfo.messenger.send(null);
    expect(await combineInfo.messenger.messages.first, 2);
    combineInfo.isolate.kill();
  });

  test('Test with complex counter', () async {
    final combineInfo = await spawnEventCounterIsolate();
    combineInfo.messenger.send(IncrementEvent());

    expect(
      await combineInfo.messenger.messages.first,
      const CounterInfoEvent(1),
    );

    combineInfo.messenger.send(IncrementEvent());
    expect(
      await combineInfo.messenger.messages.first,
      const CounterInfoEvent(2),
    );

    combineInfo.messenger.send(null);
    combineInfo.messenger.send(DecrementEvent());
    expect(
      await combineInfo.messenger.messages.first,
      const CounterInfoEvent(1),
    );

    combineInfo.messenger.send(DecrementEvent());
    expect(
      await combineInfo.messenger.messages.first,
      const CounterInfoEvent(0),
    );
    combineInfo.isolate.kill();
  });

  test(
    "Test method channel using counter which incremented in 'platform'",
    () async {
      final combineInfo = await spawnMethodChannelCounterIsolate();

      combineInfo.messenger.send(null);
      expect(await combineInfo.messenger.messages.first, 1);

      combineInfo.messenger.send(null);
      expect(await combineInfo.messenger.messages.first, 2);
      combineInfo.isolate.kill();
    },
  );

  test("Test method channel invoked from platform", () async {
    final combineInfo = await spawnComplexMethodChannelCounterIsolate();

    combineInfo.messenger.send(null);
    expect(await combineInfo.messenger.messages.first, 1);

    combineInfo.messenger.send(null);
    expect(await combineInfo.messenger.messages.first, 2);
    combineInfo.isolate.kill();
  });

  test("Can't communicate with killed isolate", () async {
    final combineInfo = await spawnSimpleCounterIsolate();
    combineInfo.isolate.kill();

    expect(
      () => combineInfo.messenger.send(""),
      throwsA(isA<IsolateClosedException>()),
    );
  });

  test('Argument is passed correctly', () async {
    const argument = CounterInfoEvent(42);
    final combineInfo = await spawnArgumentsResendIsolate(argument);
    expect(await combineInfo.messenger.messages.first, argument);
    combineInfo.isolate.kill();
  });

  test(
      'No event is lost. '
      'First event is received because argument is resend instantly. '
      'Second event is received because it is instantly send from main isolate.',
      () async {
    const argument = CounterInfoEvent(42);
    final combineInfo = await spawnInstantArgumentsResendIsolate(argument);
    combineInfo.messenger.send(argument);
    final receivedAMessages =
        await combineInfo.messenger.messages.take(2).toList();
    expect(receivedAMessages, [argument, argument]);
    combineInfo.isolate.kill();
  });
}
