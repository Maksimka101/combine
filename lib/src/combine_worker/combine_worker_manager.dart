import 'dart:async';

import 'package:combine/src/combine_isolate/combine_isolate.dart';
import 'package:combine/src/combine_worker/tasks.dart';
import 'package:combine/src/combine_worker_singleton.dart';

abstract class CombineWorkerManager {
  CombineWorkerManager();

  /// Initializes worker manager by creating [isolatesCount] [CombineIsolate]s.
  Future<void> initialize({
    WorkerInitializer? initializer,
  });

  Future<T> execute<T>(ExecutableTask<T> task);

  /// Kills all created [CombineIsolate]s.
  Future<void> close({required bool waitForRemainingTasks});
}
