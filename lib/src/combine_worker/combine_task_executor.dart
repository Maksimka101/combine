import 'dart:async';
import 'dart:collection';

import 'package:combine/src/combine_info.dart';
import 'package:combine/src/combine_isolate/combine_isolate.dart';
import 'package:combine/src/combine_singleton.dart';
import 'package:combine/src/combine_worker/tasks.dart';
import 'package:combine/src/combine_worker_singleton.dart';
import 'package:combine/src/isolate_context.dart';
import 'package:combine/src/isolate_messenger/isolate_messenger.dart';
import 'package:combine/src/method_channel_middleware/isolated_method_channel_middleware.dart';
import 'package:uuid/uuid.dart';

class CombineTaskExecutor {
  CombineTaskExecutor._(
    this._combineInfo,
    this._tasksQueue, [
    IdGenerator? idGenerator,
  ])  : _idGenerator = idGenerator ?? const Uuid().v4,
        _isolateMessenger = _combineInfo.messenger;

  final Queue<TaskInfo> _tasksQueue;
  final CombineInfo _combineInfo;
  final IdGenerator _idGenerator;
  final IsolateMessenger _isolateMessenger;
  Completer? _lastTaskCompleter;

  bool get isWorking => _lastTaskCompleter != null;

  static Future<CombineTaskExecutor> createExecutor(
    Queue<TaskInfo> actionsQueue,
  ) async {
    final combineInfo = await Combine().spawn(
      _isolateEntryPoint,
      errorsAreFatal: false,
    );
    return CombineTaskExecutor._(combineInfo, actionsQueue);
  }

  /// Executes actions from [_tasksQueue] if any and if it is not working.
  Future<void> tryToExecuteActionIfAny() async {
    if (_tasksQueue.isNotEmpty && !isWorking) {
      final task = _tasksQueue.removeFirst();
      _lastTaskCompleter = task.resultCompleter;
      await _sendMessageAndReceiveResponse(task);
      _lastTaskCompleter = null;
      unawaited(tryToExecuteActionIfAny());
    }
  }

  /// Kills [CombineIsolate].
  void close() {
    _combineInfo.isolate.kill();
    _lastTaskCompleter?.completeError(CombineWorkerClosedException());
  }

  Future<void> _sendMessageAndReceiveResponse(TaskInfo taskInfo) async {
    final taskId = _idGenerator();
    _isolateMessenger.send(_ExecutableTaskRequest(taskId, taskInfo.task));
    final response = await _isolateMessenger.messages.firstWhere(
      (msg) => msg is _ExecutableTaskResponse && msg.taskId == taskId,
    ) as _ExecutableTaskResponse;
    response.taskResponse.complete(taskInfo.resultCompleter);
  }

  static Future<void> _isolateEntryPoint(IsolateContext context) async {
    final messenger = context.messenger;
    await for (final request in messenger.messages) {
      if (request is _ExecutableTaskRequest) {
        late TaskResponse taskResponse;
        try {
          taskResponse = TaskValueResponse(await request.task.execute());
        } catch (error, stackTrace) {
          taskResponse = TaskErrorResponse(error, stackTrace);
        }
        messenger.send(_ExecutableTaskResponse(request.taskId, taskResponse));
      }
    }
  }
}

class _ExecutableTaskRequest<T> {
  _ExecutableTaskRequest(this.taskId, this.task);

  final String taskId;
  final ExecutableTask<T> task;
}

class _ExecutableTaskResponse<T> {
  _ExecutableTaskResponse(this.taskId, this.taskResponse);

  final String taskId;
  final TaskResponse<T> taskResponse;
}
