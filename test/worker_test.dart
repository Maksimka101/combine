import 'dart:developer';
import 'dart:io';

import 'package:combine/combine.dart';
import 'package:combine/src/combine_worker/worker_manager_factory/web_worker_manager_factory.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils/test_async_widgets.dart';
import 'worker_tasks/initializer_tasks.dart';
import 'worker_tasks/no_args_tasks.dart';
import 'worker_tasks/one_arg_tasks.dart';
import 'worker_tasks/two_args_tasks.dart';

void main() {
  late CombineWorker combineWorker;

  setUp(() {
    combineWorker = CombineWorkerImpl();
  });
  tearDown(() => combineWorker.close());

  group("Test with native worker factory", () {
    setUp(() {
      setTestWorkerFactory(NativeWorkerManagerFactory());
    });

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

    group("Test 'initializer' parameter for the 'initialize' method", () {
      test("initializer function is executed in the single Isolate", () async {
        await combineWorker.initialize(
          isolatesCount: 1,
          initializer: workerInitializer,
        );

        final initializerIsCalled = await combineWorker.execute(
          initializerIsCalledTask,
        );
        final calledOnce = await combineWorker.execute(
          ensureInitializerIsCalledOnceTask,
        );

        expect(initializerIsCalled, isTrue);
        expect(calledOnce, isTrue);
      });

      test("initializer function is executed in the each Isolate", () async {
        const isolatesCount = 4;
        await combineWorker.initialize(
          isolatesCount: isolatesCount,
          tasksPerIsolate: 1,
          initializer: workerInitializer,
        );

        final tasksResult = await Future.wait([
          for (var i = 0; i < isolatesCount * 4; i++)
            combineWorker.execute(
              initializerIsCalledTask,
            ),
        ]);
        expect(tasksResult.every((result) => result), isTrue);
      });
    });

    group("'UnsupportedIsolateArgumentError'", () {
      testAsyncWidgets(
        'is thrown when sending unsupported object to the isolate',
        (_) async {
          Object? exception;
          try {
            await combineWorker.executeWithArg(
              unsupportedArgumentTask,
              UserTag(""),
            );
          } catch (e) {
            exception = e;
            exception.toString();
          }
          expect(
            exception,
            isA<UnsupportedIsolateArgumentError>(),
          );
        },
      );

      testAsyncWidgets(
        'is thrown when sending unsupported object from the isolate',
        (_) async {
          await expectLater(
            combineWorker.executeWithArg(
              unsupportedArgumentTask,
              Object(),
            ),
            throwsA(isA<UnsupportedIsolateArgumentError>()),
          );
        },
      );
    });

    testAsyncWidgets('test isolate prefix', (_) async {
      await combineWorker.initialize(isolatesPrefix: 'prefix-test');
    });
  });

  group("Test with web worker factory", () {
    setUp(() {
      setTestWorkerFactory(WebWorkerManagerFactory());
    });

    tearDownAll(clearWorkerFactory);

    commonWorkerTest();

    group("Test 'initializer' parameter for the 'initialize' method", () {
      test("'initializer' is called", () async {
        await combineWorker.initialize(
          isolatesCount: 1,
          initializer: workerInitializer,
        );

        expect(initializerIsCalledTask(), isTrue);
        expect(ensureInitializerIsCalledOnceTask(), isTrue);
      });
    });
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
        combineWorker.execute(throwExceptionTask),
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

  group("Test 'executeWith3Args'", () {
    testAsyncWidgets("with add three numbers task", (_) async {
      const firstNum = 4;
      const secondNum = 8;
      const thirdNum = 1;

      final result = await combineWorker.executeWith3Args(
        addThreeNumbers,
        firstNum,
        secondNum,
        thirdNum,
      );

      expect(result, firstNum + secondNum + thirdNum);
    });
  });

  group("Test 'executeWith4Args'", () {
    testAsyncWidgets("with add four numbers task", (_) async {
      const firstNum = 4;
      const secondNum = 8;
      const thirdNum = 1;
      const fourthNum = 2;

      final result = await combineWorker.executeWith4Args(
        addFourNumbers,
        firstNum,
        secondNum,
        thirdNum,
        fourthNum,
      );

      expect(result, firstNum + secondNum + thirdNum + fourthNum);
    });
  });

  group("Test 'executeWith5Args'", () {
    testAsyncWidgets("with add five numbers task", (_) async {
      const firstNum = 4;
      const secondNum = 8;
      const thirdNum = 1;
      const fourthNum = 2;
      const fifthNum = 7;

      final result = await combineWorker.executeWith5Args(
        addFiveNumbers,
        firstNum,
        secondNum,
        thirdNum,
        fourthNum,
        fifthNum,
      );

      expect(result, firstNum + secondNum + thirdNum + fourthNum + fifthNum);
    });
  });

  group("Test 'executeWithApply'", () {
    testAsyncWidgets("with 'voidOneArgTask'", (tester) async {
      await combineWorker.executeWithApply<void>(
        voidOneArgTask,
        [Object()],
      );
    });

    testAsyncWidgets("with 'valueTask'", (tester) async {
      const value = "value";

      final result = await combineWorker.executeWithApply<String>(
        valueTask,
        [value],
      );

      expect(result, value);
    });

    testAsyncWidgets("with 'constTask'", (tester) async {
      final response = await combineWorker.executeWithApply<String>(
        constTask,
        [],
      );

      expect(response, constVoidTaskValue);
    });

    testAsyncWidgets("with 'addThreeNumbersNamed'", (_) async {
      const firstNum = 4;
      const secondNum = 8;
      const thirdNum = 1;

      final firstResponse = await combineWorker.executeWithApply(
        addThreeNumbersNamed,
        [firstNum],
        {#second: secondNum},
      );

      expect(firstResponse, firstNum + secondNum);

      final secondResponse = await combineWorker.executeWithApply(
        addThreeNumbersNamed,
        [firstNum],
        {#second: secondNum, #third: thirdNum},
      );

      expect(secondResponse, firstNum + secondNum + thirdNum);
    });
  });
}
