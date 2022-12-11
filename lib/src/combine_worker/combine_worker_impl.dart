import 'package:combine/src/combine_worker/combine_worker_manager.dart';
import 'package:combine/src/combine_worker/effective_worker_factory.dart';
import 'package:combine/src/combine_worker/tasks.dart';
import 'package:combine/src/combine_worker_singleton.dart';

class CombineWorkerImpl implements CombineWorker {
  CombineWorkerManager? _workerManager;
  CombineWorkerManager get _effectiveWorkerManager {
    return _workerManager ??= _createCombineWorkerManager();
  }

  var _isInitialized = false;

  /// {@macro combine_worker_initialize}
  @override
  Future<void> initialize({
    int? isolatesCount,
    int tasksPerIsolate = defaultTasksPerIsolate,
    WorkerInitializer? initializer,
    String isolatesPrefix = defaultIsolatePrefix,
  }) async {
    assert(
      isolatesCount == null || isolatesCount > 0,
      "`isolatesCount` must be greater than zero if specified.",
    );
    assert(
      !_isInitialized,
      "`CombineWorker` is already initialized.\n"
      "This may happen if you call some `execute` function before `initialize`.\n",
    );
    assert(
      tasksPerIsolate > 0,
      "`tasksPerIsolate` parameter must be greater that zero",
    );

    _isInitialized = true;
    _workerManager = effectiveWorkerFactory.create(
      tasksPerIsolate: tasksPerIsolate,
      isolatesCount: isolatesCount,
    );
    await _effectiveWorkerManager.initialize(
      initializer: initializer,
      isolatesPrefix: isolatesPrefix,
    );
  }

  /// {@macro combine_worker_execute}
  @override
  Future<T> execute<T>(Task<T> action) {
    return _effectiveWorkerManager.execute(NoArgsTask(action));
  }

  /// {@macro combine_worker_execute_with_arg}
  @override
  Future<T> executeWithArg<T, Q>(Task1<T, Q> action, Q argument) {
    return _effectiveWorkerManager.execute(TaskWithArg(action, argument));
  }

  /// {@macro combine_worker_execute_with_2_args}
  @override
  Future<T> executeWith2Args<T, Q, C>(
    Task2<T, Q, C> action,
    Q argument,
    C argument2,
  ) {
    return _effectiveWorkerManager.execute(
      TaskWith2Args(action, argument, argument2),
    );
  }

  /// {@macro combine_worker_close}
  @override
  Future<void> close({bool waitForRemainingTasks = false}) async {
    final closeResult = _workerManager?.close(
      waitForRemainingTasks: waitForRemainingTasks,
    );

    _workerManager = null;
    _isInitialized = false;

    return closeResult;
  }

  @override
  Future<T> executeWith3Args<T, Q, C, A>(
    Task3<T, Q, C, A> task,
    Q argument,
    C argument2,
    A argument3,
  ) {
    return _effectiveWorkerManager.execute(
      TaskWith3Args(task, argument, argument2, argument3),
    );
  }

  @override
  Future<T> executeWith4Args<T, Q, C, A, B>(
    Task4<T, Q, C, A, B> task,
    Q argument,
    C argument2,
    A argument3,
    B argument4,
  ) {
    return _effectiveWorkerManager.execute(
      TaskWith4Args(task, argument, argument2, argument3, argument4),
    );
  }

  @override
  Future<T> executeWith5Args<T, Q, C, A, B, D>(
    Task5<T, Q, C, A, B, D> task,
    Q argument,
    C argument2,
    A argument3,
    B argument4,
    D arguments5,
  ) {
    return _effectiveWorkerManager.execute(
      TaskWith5Args(
        task,
        argument,
        argument2,
        argument3,
        argument4,
        arguments5,
      ),
    );
  }

  @override
  Future<T> executeWithApply<T>(
    TaskApply task,
    List? positionalArguments, [
    Map<Symbol, dynamic>? namedArguments,
  ]) {
    return _effectiveWorkerManager.execute(
      TaskWithApplyArgs(task, positionalArguments, namedArguments),
    );
  }

  CombineWorkerManager _createCombineWorkerManager() {
    _isInitialized = true;
    return effectiveWorkerFactory.create()
      ..initialize(isolatesPrefix: defaultIsolatePrefix);
  }
}
