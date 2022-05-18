import 'dart:async';

abstract class ExecutableTask<T> {
  const ExecutableTask();

  FutureOr<T> execute();
}

class NoArgsTask<T> extends ExecutableTask<T> {
  const NoArgsTask(this.task);

  final Task<T> task;

  @override
  FutureOr<T> execute() => task();
}

class TaskWithArg<T, Q> extends ExecutableTask<T> {
  const TaskWithArg(this.task, this.argument);

  final Task1<T, Q> task;
  final Q argument;

  @override
  FutureOr<T> execute() => task(argument);
}

class TaskWith2Args<T, Q, C> extends ExecutableTask<T> {
  const TaskWith2Args(
    this.task,
    this.argument,
    this.argument2,
  );

  final Task3<T, Q, C> task;
  final Q argument;
  final C argument2;

  @override
  FutureOr<T> execute() => task(argument, argument2);
}

class TaskInfo<T> {
  const TaskInfo(this.task, this.resultCompleter);

  final ExecutableTask<T> task;
  final Completer<T> resultCompleter;
}

abstract class TaskResponse<T> {
  const TaskResponse();

  void complete(Completer<T> completer);
}

class TaskValueResponse<T> extends TaskResponse<T> {
  const TaskValueResponse(this.data);

  final T data;

  @override
  void complete(Completer<T> completer) {
    if (!completer.isCompleted) {
      completer.complete(data);
    }
  }
}

class TaskErrorResponse<T> extends TaskResponse<T> {
  const TaskErrorResponse(this.error, this.stackTrace);

  final Object error;
  final StackTrace stackTrace;

  @override
  void complete(Completer<T> completer) {
    if (!completer.isCompleted) {
      completer.completeError(error, stackTrace);
    }
  }
}

typedef Task<T> = FutureOr<T> Function();

typedef Task1<T, Q> = FutureOr<T> Function(Q argument);

typedef Task3<T, Q, C> = FutureOr<T> Function(Q argument1, C argument2);
