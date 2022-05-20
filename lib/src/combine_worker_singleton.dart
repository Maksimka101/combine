import 'dart:async';

import 'package:combine/src/combine_isolate/combine_isolate.dart';
import 'package:combine/src/combine_singleton.dart';
import 'package:combine/src/combine_worker/combine_worker_impl.dart';
import 'package:combine/src/combine_worker/tasks.dart';
import 'package:flutter/foundation.dart';

const defaultTasksPerIsolate = 2;

/// {@template combine_worker_singleton}
/// Combine Worker is a pool of [CombineIsolate]s that efficiently executes
/// tasks in them. It is primarily used to reduce the number of isolates
/// and provide more performant and easy way to execute tasks.
///
/// In comparison to Fluter's [compute] method which creates an isolate each time
/// it's called, Combine Worker creates a pool of isolates and efficiently
/// reuses them. At the same time, it has all of the advantages of [CombineIsolate],
/// allowing you to work with platform channels in an isolate.
///
/// If you want to create a single [CombineIsolate], take a look at [Combine].
/// {@endtemplate}
abstract class CombineWorker {
  /// {@macro combine_worker_singleton}
  factory CombineWorker() => _instance;
  static late final _instance = CombineWorkerImpl();

  /// {@template combine_worker_initialize}
  /// Initializes worker.
  ///
  /// Worker manager can be lazily initialized on the first execution,
  /// so you can omit calling `initialize`.
  ///
  /// To initialize worker with a custom amount of isolates, use the
  /// [isolatesCount] parameter.
  /// Default value is calculated by the following formula:
  /// `max(1, (numberOfProcessors / 2).floor())`
  /// Please keep in mind that Flutter already uses 3 threads:
  /// Dart main, native main and GPU. So your [isolatesCount] should be less
  /// than `numberOfProcessors - 3`.
  ///
  /// Each isolate can execute one or more tasks asynchronously
  /// (thanks to async IO and event loop).
  /// [tasksPerIsolate] parameter is used to set maximum number of tasks that
  /// one isolate can perform asynchronously.
  /// {@endtemplate}
  Future<void> initialize({
    int? isolatesCount,
    int tasksPerIsolate = defaultTasksPerIsolate,
  });

  /// {@template combine_worker_execute}
  /// Executes given [task] in combine isolate.
  /// {@endtemplate}
  ///
  /// {@template combine_worker_execute_exception}
  /// This future may complete with [CombineWorkerClosedException] if you
  /// [close] worker with `waitForRemainingTasks` flag set to `false`.
  /// {@endtemplate}
  Future<T> execute<T>(Task<T> task);

  /// {@template combine_worker_execute_with_arg}
  /// Executes given [task] with given [argument] in combine isolate.
  /// {@endtemplate}
  ///
  /// {@macro combine_worker_execute_exception}
  Future<T> executeWithArg<T, Q>(Task1<T, Q> task, Q argument);

  /// {@template combine_worker_execute_with_2_args}
  /// Executes given [task] with given [argument] and [argument2] in combine isolate.
  /// {@endtemplate}
  ///
  /// {@macro combine_worker_execute_exception}
  Future<T> executeWith2Args<T, Q, C>(
    Task3<T, Q, C> task,
    Q argument,
    C argument2,
  );

  /// {@template combine_worker_close}
  /// Closes the current Worker.
  /// [CombineWorker] is a singleton but under the hood it uses a worker manager instance
  /// which can be closed and recreated. It may be useful if you want to cancel
  /// all running and awaiting tasks (i. e. on user logout).
  ///
  /// If `waitForRemainingTasks` flag is set to `true` then
  /// worker will be marked as closed but will finish all its tasks.
  /// Otherwise all remaining tasks will complete with [CombineWorkerClosedException].
  ///
  /// You can call [execute] or [initialize] methods without awaiting for this future.
  /// In that case new isolates' pool will be created.
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
