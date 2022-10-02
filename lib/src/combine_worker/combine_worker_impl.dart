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
    await _effectiveWorkerManager.initialize(initializer: initializer);
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
    Task3<T, Q, C> action,
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

  CombineWorkerManager _createCombineWorkerManager() {
    _isInitialized = true;
    return effectiveWorkerFactory.create()..initialize();
  }
}
