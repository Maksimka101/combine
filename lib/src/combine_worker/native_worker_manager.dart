import 'dart:async';
import 'dart:collection';

import 'package:combine/src/combine_worker/combine_task_executor.dart';
import 'package:combine/src/combine_worker/combine_worker_manager.dart';
import 'package:combine/src/combine_worker/tasks.dart';
import 'package:combine/src/combine_worker_singleton.dart';

class NativeWorkerManager extends CombineWorkerManager {
  NativeWorkerManager(this.isolatesCount);

  final int isolatesCount;
  final _taskExecutors = <CombineTaskExecutor>[];
  final _tasksQueue = Queue<TaskInfo>();
  final _initializationCompleter = Completer();
  final _lastTaskCompleter = Completer();
  var _isClosed = false;

  @override
  Future<void> initialize() async {
    assert(
      !_initializationCompleter.isCompleted,
      "Internal error. Worker manager is initialized twice.",
    );
    await Future.wait(
      [
        for (var i = 0; i < isolatesCount; i++)
          CombineTaskExecutor.createExecutor(
            _tasksQueue,
          ).then(_addTaskExecutor),
      ],
    );
    _initializationCompleter.complete();
  }

  void _addTaskExecutor(CombineTaskExecutor taskExecutor) {
    _taskExecutors.add(taskExecutor);
    _tryToStartExecution();
  }

  @override
  Future<T> execute<T>(ExecutableTask<T> task) async {
    assert(!_isClosed, "Internal error. Can't execute task in closed manager");

    final completer = Completer();
    _tasksQueue.add(TaskInfo(task, completer));
    _tryToStartExecution();
    final result = await completer.future;
    _markLastTaskAsCompletedIfNeeded();
    return result;
  }

  @override
  Future<void> close({bool waitForRemainingTasks = false}) async {
    // Ensure that initialization is completed and isolates are created.
    await _initializationCompleter.future;
    assert(
      _taskExecutors.isNotEmpty,
      "Internal error. "
      "Seems like initialization is incomplete and isolates are not created",
    );
    _isClosed = true;

    if (waitForRemainingTasks) {
      _markLastTaskAsCompletedIfNeeded();
      await _lastTaskCompleter.future;
    } else {
      for (final task in _tasksQueue) {
        task.resultCompleter.completeError(CombineWorkerClosedException());
      }
    }

    for (final taskExecutor in _taskExecutors) {
      taskExecutor.close();
    }
  }

  /// This function is used to wait for remaining tasks when worker is closed with corresponding parameter.
  void _markLastTaskAsCompletedIfNeeded() {
    final executorsAreWorking = _taskExecutors.any(
      (executor) => executor.isWorking,
    );
    if (_isClosed && !executorsAreWorking && _tasksQueue.isEmpty) {
      _lastTaskCompleter.complete();
    }
  }

  void _tryToStartExecution() {
    for (final taskQueue in _taskExecutors) {
      unawaited(taskQueue.tryToExecuteActionIfAny());
    }
  }
}