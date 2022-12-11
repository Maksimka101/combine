import 'dart:async';

import 'package:combine/combine.dart';

class WebWorkerManager extends CombineWorkerManager {
  @override
  Future<void> initialize({
    WorkerInitializer? initializer,
    required String isolatesPrefix,
  }) async {
    initializer?.call();
  }

  @override
  Future<T> execute<T>(ExecutableTask<T> task) async {
    await null;
    return task.execute();
  }

  @override
  Future<void> close({required bool waitForRemainingTasks}) async {}
}
