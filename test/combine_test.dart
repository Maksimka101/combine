import 'package:combine/src/binary_messenger_middleware/ui_binary_messenger_middleware.dart';
import 'package:combine/src/combine_singleton.dart';
import 'package:combine/src/isolate_factory/effective_isolate_factory.dart';
import 'package:combine/src/isolate_factory/native_isolate_factory.dart';
import 'package:combine/src/isolate_factory/web_isolate_factory.dart';
import 'package:combine/src/isolate_messenger/internal_isolate_messenger/internal_isolate_messenger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'combine_spawners/arguments_resend_combine_spawner.dart';
import 'combine_spawners/counter_combine_spawners.dart';
import 'mocks/mock_isolate_factory.dart';

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

        expect(
          UIBinaryMessengerMiddleware.uiBinaryMessengerMiddleware,
          isNotEmpty,
        );
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

  test(
    "'Combine.spawn' calls 'effectiveIsolateFactory.create' correctly",
    () async {
      final isolateFactory = MockIsolateFactory();
      registerFallbackValue(FakeRootIsolateToken());
      setTestIsolateFactory(isolateFactory);

      void entryPoint(_) {}
      const errorsAreFatal = false;
      const debugName = 'debugName';

      when(
        () => isolateFactory.create(
          entryPoint,
          argument: debugName,
          debugName: debugName,
          errorsAreFatal: errorsAreFatal,
          isolateToken: any(named: "isolateToken"),
        ),
      ).thenAnswer((_) async => FakeCombineInfo());

      await Combine().spawn(
        entryPoint,
        errorsAreFatal: errorsAreFatal,
        debugName: debugName,
        argument: debugName,
        // Don't pass isolate token because this test tests isolate token creation.
        // isolateToken:
      );

      verify(
        () => isolateFactory.create(
          entryPoint,
          errorsAreFatal: errorsAreFatal,
          debugName: debugName,
          argument: debugName,
          isolateToken: getRootIsolateToken(isWeb: kIsWeb),
        ),
      ).called(1);
    },
  );

  test("'getRootIsolateToken' returns null on web", () {
    expect(getRootIsolateToken(isWeb: true), isNull);
  });
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

  test(
    timeout: const Timeout(Duration(seconds: 5)),
    "Combine Isolate created inside another Combine Isolate is working fine",
    () async {
      final combineInfo = await spawnSimpleCounterIsolateInsideAnotherIsolate();

      /// Wait when isolate will be initialized.
      await combineInfo.messenger.messages.first;
      combineInfo.messenger.send(null);
      expect(await combineInfo.messenger.messages.first, 1);

      combineInfo.messenger.send(null);
      expect(await combineInfo.messenger.messages.first, 2);
      combineInfo.isolate.kill();
    },
  );
}
