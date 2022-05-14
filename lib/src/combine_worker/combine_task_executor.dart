import 'dart:async';
import 'dart:collection';

import 'package:combine/src/combine_info.dart';
import 'package:combine/src/combine_singleton.dart';
import 'package:combine/src/combine_worker/tasks.dart';
import 'package:combine/src/isolate_context.dart';

class CombineTaskExecutor {
  CombineTaskExecutor._(this.combineInfo, this._actionsQueue);

  final Queue<TaskInfo> _actionsQueue;
  final CombineInfo combineInfo;

  static Future<CombineTaskExecutor> initializeExecutor(
    Queue<TaskInfo> actionsQueue,
  ) async {
    final combineInfo = await Combine().spawn(
      _isolateEntryPoint,
      errorsAreFatal: false,
    );
    return CombineTaskExecutor._(combineInfo, actionsQueue);
  }

  /// Executes actions from [_actionsQueue] if any.
  Future<void> executeActionIfAny() async {
    if (_actionsQueue.isNotEmpty) {
      final action = _actionsQueue.removeFirst();
      await _sendMessageAndReceiveResponse(combineInfo, action);
      unawaited(executeActionIfAny());
    }
  }

  Future<void> _sendMessageAndReceiveResponse<T>(
    CombineInfo combineInfo,
    TaskInfo taskInfo,
  ) async {
    final messenger = combineInfo.messenger;
    messenger.send(taskInfo.task);
    final response = await messenger.messages.firstWhere(
      (message) => message is TaskResponse && message.id == taskInfo.task.id,
    ) as TaskResponse;
    response.complete(taskInfo.resultCompleter);
  }

  static void _isolateEntryPoint(IsolateContext context) {
    final messenger = context.messenger;
    messenger.messages.listen((event) async {
      if (event is ExecutableTask) {
        try {
          final result = await event.execute();
          messenger.send(TaskValueResponse(event.id, result));
        } catch (error, stackTrace) {
          messenger.send(TaskErrorResponse(event.id, error, stackTrace));
        }
      }
    });
  }
}
