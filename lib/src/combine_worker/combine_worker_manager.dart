import 'dart:async';

import 'package:combine/src/combine_isolate/combine_isolate.dart';
import 'package:combine/src/combine_worker/tasks.dart';

abstract class CombineWorkerManager {
  CombineWorkerManager();

  /// Initializes worker manager by creating [isolatesCount] [CombineIsolate]s.
  Future<void> initialize();

  Future<T> execute<T>(ExecutableTask<T> task);
}
