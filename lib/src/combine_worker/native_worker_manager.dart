import 'dart:async';
import 'dart:collection';

import 'package:combine/src/combine_worker/combine_task_executor.dart';
import 'package:combine/src/combine_worker/combine_worker_manager.dart';
import 'package:combine/src/combine_worker/tasks.dart';

class NativeWorkerManager extends CombineWorkerManager {
  NativeWorkerManager(this.isolatesCount);

  final int isolatesCount;
  var _taskQueues = <CombineTaskExecutor>[];
  final _actionsQueue = Queue<TaskInfo>();

  @override
  Future<void> initialize() async {
    _taskQueues = await Future.wait(
      [
        for (var i = 0; i < isolatesCount; i++)
          CombineTaskExecutor.initializeExecutor(_actionsQueue),
      ],
    );
    await _tryToStartExecution();
  }

  @override
  Future<T> execute<T>(ExecutableTask<T> task) {
    final completer = Completer<T>();
    _actionsQueue.add(TaskInfo(task, completer));
    _tryToStartExecution();
    return completer.future;
  }

  void addTasksAndExecute(List<TaskInfo> tasks) {
    _actionsQueue.addAll(tasks);
    _tryToStartExecution();
  }

  Future<void> _tryToStartExecution() async {
    for (final taskQueue in _taskQueues) {
      unawaited(taskQueue.executeActionIfAny());
    }
  }
}
