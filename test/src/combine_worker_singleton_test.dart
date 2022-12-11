import 'package:combine/combine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks/executable_task_fake.dart';
import '../mocks/mock_combine_worker_factory.dart';
import '../mocks/mock_combine_worker_manager.dart';

void main() {
  late CombineWorkerManagerFactory combineWorkerManagerFactory;
  late CombineWorkerManager combineWorkerManager;
  late CombineWorker combineWorker;

  setUp(() {
    combineWorkerManagerFactory = MockCombineWorkerManagerFactory();
    combineWorkerManager = MockCombineWorkerManager();
    combineWorker = CombineWorkerImpl();

    registerFallbackValue(ExecutableTaskFake<String>());

    when(
      () => combineWorkerManager.initialize(
        isolatesPrefix: any(named: 'isolatesPrefix'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => combineWorkerManagerFactory.create(
        isolatesCount: any(named: 'isolatesCount'),
      ),
    ).thenReturn(combineWorkerManager);
    when(
      () => combineWorkerManager.execute<String>(any()),
    ).thenAnswer((_) async => "");

    setTestWorkerFactory(combineWorkerManagerFactory);
  });

  void verifyCreated([Matcher? countsMatcher]) {
    verify(
      () => combineWorkerManagerFactory.create(
        isolatesCount: any(named: 'isolatesCount', that: countsMatcher),
      ),
    ).called(1);
  }

  void verifyExecuted([Matcher? taskMatcher]) {
    verify(
      () => combineWorkerManager.execute<String>(any(that: taskMatcher)),
    ).called(1);
  }

  test("'CombineWorker' is a singleton", () {
    expect(identical(CombineWorker(), CombineWorker()), isTrue);
  });

  test("'CombineWorker.newInstance' factory creates a new instance", () {
    final singleton = CombineWorker();
    final firstInstance = CombineWorker.newInstance();
    final secondInstance = CombineWorker.newInstance();

    expect(identical(singleton, firstInstance), isFalse);
    expect(identical(singleton, secondInstance), isFalse);
    expect(identical(firstInstance, secondInstance), isFalse);
  });

  test("'initialize' calls worker manager's initialize function", () async {
    await combineWorker.initialize(isolatesCount: 10);
    verifyCreated(equals(10));
  });

  test("'execute' function", () async {
    await combineWorker.execute<String>(() => "");
    verifyCreated();
    verifyExecuted(isA<NoArgsTask>());
  });

  test("'executeWithArg' function", () async {
    await combineWorker.executeWithArg<String, Object>((_) => "", Object());
    verifyCreated();
    verifyExecuted(isA<TaskWithArg>());
  });

  test("'executeWith2Args' function", () async {
    await combineWorker.executeWith2Args<String, Object, Object>(
      (_, __) => "",
      Object(),
      Object(),
    );
    verifyCreated();
    verifyExecuted(isA<TaskWith2Args>());
  });
}
