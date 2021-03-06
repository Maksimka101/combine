import 'dart:io';

import 'package:combine/combine.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils/test_async_widgets.dart';
import 'worker_tasks/no_args_tasks.dart';
import 'worker_tasks/one_arg_tasks.dart';
import 'worker_tasks/two_args_tasks.dart';

void main() {
  group("Test with native worker factory", () {
    late CombineWorker combineWorker;

    setUp(() {
      setTestWorkerFactory(NativeWorkerManagerFactory());
      combineWorker = CombineWorkerImpl();
    });

    tearDown(() => combineWorker.close());
    tearDownAll(clearWorkerFactory);

    commonWorkerTest();

    test("'calculateIsolatesCount' returns valid number", () {
      clearTestIsolatesCount();
      final nativeWorkerFactory = NativeWorkerManagerFactory();
      final isolatesCount = nativeWorkerFactory.calculateIsolatesCount();

      expect(isolatesCount, lessThanOrEqualTo(Platform.numberOfProcessors));
      expect(isolatesCount, greaterThan(0));
    });

    group("Test 'close' method", () {
      testAsyncWidgets("'close' with 'waitForRemainingTasks: true'", (_) async {
        final resultsFutures = [
          for (var i = 0; i < 6; i++) combineWorker.execute(delayedConstTask),
        ];
        await combineWorker.close(waitForRemainingTasks: true);

        expect(
          await Future.wait(resultsFutures),
          equals(resultsFutures.map((e) => constVoidTaskValue)),
        );
      });

      testAsyncWidgets(
        "'close' with 'waitForRemainingTasks: false'",
        (tester) async {
          final resultsFutures = [
            for (var i = 0; i < 6; i++) combineWorker.execute(delayedConstTask),
          ];
          await combineWorker.close();

          Object exception;
          try {
            await Future.wait(resultsFutures);
            exception = "no exception";
          } catch (e) {
            exception = e;
          }
          expect(exception, isA<CombineWorkerClosedException>());
        },
      );
    });
  });

  group("Test with web worker factory", () {
    setUp(() {
      setTestWorkerFactory(WebWorkerManagerFactory());
    });

    tearDownAll(clearWorkerFactory);

    commonWorkerTest();
  });

  test("'effectiveWorkerFactory' returns Native factory", () {
    final factory = effectiveWorkerFactory;

    expect(factory, isA<NativeWorkerManagerFactory>());
  });

  test("'CombineWorkerClosedException' has some description", () {
    final exception = CombineWorkerClosedException();
    expect(exception.toString(), isNot(exception.runtimeType.toString()));
    expect(exception.toString(), isNotEmpty);
  });
}

void commonWorkerTest() {
  late CombineWorker combineWorker;

  setUp(() {
    combineWorker = CombineWorkerImpl();
    setTestIsolatesCount(2);
  });

  tearDown(() async {
    await combineWorker.close();
    clearTestIsolatesCount();
  });

  group("Test 'execute' without arguments", () {
    testAsyncWidgets("with void Task", (tester) async {
      await combineWorker.execute(voidEmptyTask);
    });

    testAsyncWidgets("with constTask", (tester) async {
      final response = await combineWorker.execute(constTask);

      expect(response, constVoidTaskValue);
    });

    testAsyncWidgets("with throw exception task", (_) async {
      await expectLater(
        () => combineWorker.execute(throwExceptionTask),
        throwsException,
      );
    });
  });

  group("Test 'executeWithArg'", () {
    testAsyncWidgets("with void task", (tester) async {
      await combineWorker.executeWithArg(voidOneArgTask, Object());
    });

    testAsyncWidgets("with value task", (tester) async {
      const value = "value";

      final result = await combineWorker.executeWithArg(valueTask, value);

      expect(result, value);
    });

    testAsyncWidgets("with increment task", (tester) async {
      const value = 0;

      final result = await combineWorker.executeWithArg(incrementTask, value);

      expect(result, value + 1);
    });
  });

  group("Test 'executeWith2Args'", () {
    testAsyncWidgets("with add two numbers task", (_) async {
      const firstNum = 4;
      const secondNum = 8;

      final result = await combineWorker.executeWith2Args(
        addTwoNumbers,
        firstNum,
        secondNum,
      );

      expect(result, firstNum + secondNum);
    });
  });
}
