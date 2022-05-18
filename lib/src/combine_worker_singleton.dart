import 'dart:async';

import 'package:combine/src/combine_worker/combine_worker_impl.dart';
import 'package:combine/src/combine_worker/tasks.dart';

abstract class CombineWorker {
  factory CombineWorker() => _instance;
  static late final _instance = CombineWorkerImpl();

  /// {@template combine_worker_initialize}
  /// Initializes worker.
  ///
  /// Worker manager can be lazy initialized
  /// so you don't need to call this function.
  /// You should call it only if you need to initialize worker manager with
  /// specified [isolatesCount] or initialize it before app's initialization.
  /// {@endtemplate}
  Future<void> initialize({int? isolatesCount});

  /// {@template combine_worker_execute}
  /// {@endtemplate}
  Future<T> execute<T>(Task<T> action);

  /// {@template combine_worker_execute_with_arg}
  /// {@endtemplate}
  Future<T> executeWithArg<T, Q>(Task1<T, Q> action, Q argument);

  /// {@template combine_worker_execute_with_2_args}
  /// {@endtemplate}
  Future<T> executeWith2Args<T, Q, C>(
    Task3<T, Q, C> action,
    Q argument,
    C argument2,
  );

  /// {@template combine_worker_close}
  /// Closes current Worker.
  /// 
  /// You can re initialize 
  /// {@endtemplate}
  Future<void> close({bool waitForRemainingTasks = false});
}

class CombineWorkerClosedException implements Exception {
  @override
  String toString() {
    return "CombineWorker has been `close`d with `waitForRemainingTasks: false`. "
        "So task can't be finished.\n"
        "If you want to close Worker and wait for remaining tasks call "
        "`close` function with `waitForRemainingTasks: false` parameter.";
  }
}
