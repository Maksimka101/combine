import 'dart:async';
import 'dart:collection';

import 'package:combine/src/combine_info.dart';
import 'package:combine/src/combine_isolate/combine_isolate.dart';
import 'package:combine/src/combine_singleton.dart';
import 'package:combine/src/combine_worker/tasks.dart';
import 'package:combine/src/combine_worker_singleton.dart';
import 'package:combine/src/id_generator.dart/id_generator.dart';
import 'package:combine/src/isolate_context.dart';
import 'package:combine/src/isolate_messenger/isolate_messenger.dart';

class CombineTaskExecutor {
  CombineTaskExecutor._(
    this._combineInfo,
    this._tasksQueue,
    this._tasksPerIsolate, [
    IdGenerator? idGenerator,
  ])  : _idGenerator = idGenerator = IdGenerator(),
        _isolateMessenger = _combineInfo.messenger;

  final Queue<TaskInfo> _tasksQueue;
  final CombineInfo _combineInfo;
  final IdGenerator _idGenerator;
  final IsolateMessenger _isolateMessenger;
  final int _tasksPerIsolate;
  final List<Completer> _currentTasksCompleters = [];

  bool get isFullOfTasks => _currentTasksCompleters.length == _tasksPerIsolate;
  bool get isWorking => _currentTasksCompleters.isNotEmpty;

  static Future<CombineTaskExecutor> createExecutor(
    Queue<TaskInfo> actionsQueue,
    int tasksPerIsolate,
    WorkerInitializer? initializer,
    String debugName,
  ) async {
    final combineInfo = await Combine().spawn(
      _isolateEntryPoint,
      argument: initializer,
      errorsAreFatal: false,
      debugName: debugName,
    );
    return CombineTaskExecutor._(combineInfo, actionsQueue, tasksPerIsolate);
  }

  /// Executes actions from [_tasksQueue] if any and if it is not working.
  Future<void> tryToExecuteActionIfAny() async {
    if (_tasksQueue.isNotEmpty && !isFullOfTasks) {
      final task = _tasksQueue.removeFirst();
      _currentTasksCompleters.add(task.resultCompleter);
      await _sendMessageAndReceiveResponse(task);
      _currentTasksCompleters.remove(task.resultCompleter);
      unawaited(tryToExecuteActionIfAny());
    }
  }

  /// Kills [CombineIsolate].
  void close() {
    _combineInfo.isolate.kill();
    for (final currentTaskCompleter in _currentTasksCompleters) {
      currentTaskCompleter.completeError(CombineWorkerClosedException());
    }
  }

  Future<void> _sendMessageAndReceiveResponse(TaskInfo taskInfo) async {
    try {
      final taskId = _idGenerator();
      _isolateMessenger.send(_ExecutableTaskRequest(taskId, taskInfo.task));
      final _ExecutableTaskResponse response = await _isolateMessenger //
          .messages
          .firstWhere(
        (msg) => msg is _ExecutableTaskResponse && msg.taskId == taskId,
      ) as dynamic;
      response.taskResponse.complete(taskInfo.resultCompleter);
    } catch (error, stackTrace) {
      taskInfo.resultCompleter.completeError(error, stackTrace);
    }
  }

  static Future<void> _isolateEntryPoint(IsolateContext context) async {
    final initializer = context.argument;
    final messenger = context.messenger;

    if (initializer is WorkerInitializer) {
      await initializer();
    }
    messenger.messages.listen((request) async {
      if (request is _ExecutableTaskRequest) {
        late TaskResponse taskResponse;
        try {
          taskResponse = TaskValueResponse(await request.task.execute());
        } catch (error, stackTrace) {
          taskResponse = TaskErrorResponse(error, stackTrace);
        }
        try {
          messenger.send(_ExecutableTaskResponse(request.taskId, taskResponse));
        } catch (error, stackTrace) {
          messenger.send(
            _ExecutableTaskResponse(
              request.taskId,
              TaskErrorResponse(error, stackTrace),
            ),
          );
        }
      }
    });
  }
}

class _ExecutableTaskRequest<T> {
  _ExecutableTaskRequest(this.taskId, this.task);

  final int taskId;
  final ExecutableTask<T> task;
}

class _ExecutableTaskResponse<T> {
  _ExecutableTaskResponse(this.taskId, this.taskResponse);

  final int taskId;
  final TaskResponse<T> taskResponse;
}
