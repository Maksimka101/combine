import 'dart:async';
import 'dart:isolate';

import 'package:combine/src/combine_isolate/combine_isolate.dart';
import 'package:combine/src/combine_singleton.dart';
import 'package:combine/src/combine_worker/combine_worker_impl.dart';
import 'package:combine/src/combine_worker/tasks.dart';
import 'package:flutter/foundation.dart';

const defaultTasksPerIsolate = 2;
const defaultIsolatePrefix = 'combine-worker';

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

  /// Creates a new instance of the [CombineWorker].
  factory CombineWorker.newInstance() => CombineWorkerImpl();

  static late final _instance = CombineWorker.newInstance();

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
  ///
  /// [initializer] is a function that will be executed in the each worker
  /// isolate. It can be used to initialize something in the worker isolate.
  ///
  /// [isolatesPrefix] will be used to set isolates debug name. Debug name will
  /// be visible in the debugger.
  /// {@endtemplate}
  Future<void> initialize({
    int? isolatesCount,
    int tasksPerIsolate = defaultTasksPerIsolate,
    WorkerInitializer? initializer,
    String isolatesPrefix = defaultIsolatePrefix,
  });

  /// {@template combine_worker_execute}
  /// Executes given [task] in combine isolate.
  /// {@endtemplate}
  ///
  /// {@template combine_worker_execute_exception}
  /// This future may complete with:
  /// - [CombineWorkerClosedException] if you [close] worker
  ///   with `waitForRemainingTasks` flag set to `false`.
  /// - [UnsupportedIsolateArgumentError] if you send to/from isolate
  ///   some unsupported object like [ReceivePort].
  /// - an original exception thrown by the [task].
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
    Task2<T, Q, C> task,
    Q argument,
    C argument2,
  );

  /// {@template combine_worker_execute_with_multiple_args}
  /// Executes given [task] with given arguments in combine isolate.
  /// {@endtemplate}
  ///
  /// {@macro combine_worker_execute_exception}
  Future<T> executeWith3Args<T, Q, C, A>(
    Task3<T, Q, C, A> task,
    Q argument,
    C argument2,
    A argument3,
  );

  /// {@template combine_worker_execute_with_multiple_args}
  /// Executes given [task] with given arguments in combine isolate.
  /// {@endtemplate}
  ///
  /// {@macro combine_worker_execute_exception}
  Future<T> executeWith4Args<T, Q, C, A, B>(
    Task4<T, Q, C, A, B> task,
    Q argument,
    C argument2,
    A argument3,
    B argument4,
  );

  /// {@template combine_worker_execute_with_multiple_args}
  /// Executes given [task] with given arguments in combine isolate.
  /// {@endtemplate}
  ///
  /// {@macro combine_worker_execute_exception}
  Future<T> executeWith5Args<T, Q, C, A, B, D>(
    Task5<T, Q, C, A, B, D> task,
    Q argument,
    C argument2,
    A argument3,
    B argument4,
    D argument5,
  );

  /// {@template combine_worker_execute_with_multiple_args}
  /// Dynamically execute [task] with the specified arguments in combine isolate
  /// It works like [Function.apply].
  ///
  /// Acts the same as calling function with positional arguments
  /// corresponding to the elements of [positionalArguments] and
  /// named arguments corresponding to the elements of [namedArguments].
  ///
  /// This includes giving the same errors if [task] isn't callable or
  /// if it expects different parameters.
  ///
  /// Don't use this method while you can use [executeWith5Args],
  /// [executeWith4Args], [executeWith3Args] etc.
  /// These methods are typesafe unlike [executeWithApply].
  /// {@endtemplate}
  ///
  /// {@macro combine_worker_execute_exception}
  Future<T> executeWithApply<T>(
    TaskApply task,
    List<dynamic> positionalArguments, [
    Map<Symbol, dynamic>? namedArguments,
  ]);

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

/// Typedef for the function that will be executed in the each worker isolate.
typedef WorkerInitializer = FutureOr<void> Function();

class CombineWorkerClosedException implements Exception {
  @override
  String toString() {
    return "The CombineWorker has been `close`d with `waitForRemainingTasks: false`. "
        "So task can't be finished.\n"
        "If you want to close the Worker and wait for remaining tasks call the "
        "`close` method with the `waitForRemainingTasks: false` parameter.";
  }
}

/// This exception is thrown when when you send to/from isolate some unsupported data like [ReceivePort].
class UnsupportedIsolateArgumentError extends ArgumentError {
  UnsupportedIsolateArgumentError(this.originalError);

  final ArgumentError originalError;

  /// Name of the invalid argument, if available.
  @override
  String? get name => originalError.name;

  /// Message describing the problem.
  @override
  dynamic get message => originalError.message;
}
