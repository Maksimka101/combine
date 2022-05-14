import 'dart:async';

import 'package:combine/src/combine_worker/combine_worker_manager.dart';
import 'package:combine/src/combine_worker/effective_worker_factory.dart';
import 'package:combine/src/combine_worker/tasks.dart';
import 'package:combine/src/method_channel_middleware/isolated_method_channel_middleware.dart';
import 'package:uuid/uuid.dart';

class CombineWorker {
  factory CombineWorker() => _instance;
  CombineWorker._();
  static late final _instance = CombineWorker._();

  late CombineWorkerManager _workerManager = _createCombineWorkerManager();
  var _isInitialized = false;
  IdGenerator idGenerator = const Uuid().v4;

  /// Initializes worker.
  ///
  /// Worker manager can be lazy initialized
  /// so you don't need to call this function.
  /// You should call it only if you need to initialize worker manager with
  /// specified [isolatesCount] or initialize it before app's initialization.
  Future<void> initialize({int? isolatesCount}) async {
    assert(
      isolatesCount == null || isolatesCount > 0,
      "`isolatesCount` must be greater than zero if specified.",
    );
    assert(
      !_isInitialized,
      "`CombineWorker` is already initialized.\n"
      "This may happen if you call some `execute` function before `initialize`.\n",
    );

    _isInitialized = true;
    _workerManager = effectiveWorkerFactory.create(
      isolatesCount: isolatesCount,
    );
    await _workerManager.initialize();
  }

  Future<T> execute<T>(Task<T> action) {
    return _workerManager.execute(NoArgsTask(action, idGenerator()));
  }

  Future<T> executeWithArg<T, Q>(Task1<T, Q> action, Q argument) {
    return _workerManager.execute(
      TaskWithArg(action, argument, idGenerator()),
    );
  }

  Future<T> executeWith2Args<T, Q, C>(
    Task3<T, Q, C> action,
    Q argument,
    C argument2,
  ) {
    return _workerManager.execute(
      TaskWith2Args(action, argument, argument2, idGenerator()),
    );
  }

  CombineWorkerManager _createCombineWorkerManager() {
    _isInitialized = true;
    return effectiveWorkerFactory.create()..initialize();
  }
}
