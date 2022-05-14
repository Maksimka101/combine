import 'dart:async';

abstract class ExecutableTask<T> {
  ExecutableTask(this.id);

  final String id;

  FutureOr<T> execute();
}

class NoArgsTask<T> extends ExecutableTask<T> {
  NoArgsTask(this.task, String id) : super(id);

  final Task<T> task;

  @override
  FutureOr<T> execute() {
    return task();
  }
}

class TaskWithArg<T, Q> extends ExecutableTask<T> {
  TaskWithArg(this.task, this.argument, String id) : super(id);

  final Task1<T, Q> task;
  final Q argument;

  @override
  FutureOr<T> execute() {
    return task(argument);
  }
}

class TaskWith2Args<T, Q, C> extends ExecutableTask<T> {
  TaskWith2Args(
    this.task,
    this.argument,
    this.argument2,
    String id,
  ) : super(id);

  final Task3<T, Q, C> task;
  final Q argument;
  final C argument2;

  @override
  FutureOr<T> execute() {
    return task(argument, argument2);
  }
}

class TaskInfo<T> {
  TaskInfo(this.task, this.resultCompleter);

  final ExecutableTask<T> task;
  final Completer<T> resultCompleter;
}

abstract class TaskResponse<T> {
  TaskResponse(this.id);

  final String id;

  void complete(Completer<T> completer);
}

class TaskValueResponse<T> extends TaskResponse<T> {
  TaskValueResponse(String id, this.data) : super(id);

  final T data;

  @override
  void complete(Completer<T> completer) {
    completer.complete(data);
  }
}

class TaskErrorResponse<T> extends TaskResponse<T> {
  TaskErrorResponse(String id, this.error, this.stackTrace) : super(id);

  final Object error;
  final StackTrace stackTrace;

  @override
  void complete(Completer<T> completer) {
    completer.completeError(error, stackTrace);
  }
}

typedef Task<T> = FutureOr<T> Function();

typedef Task1<T, Q> = FutureOr<T> Function(Q argument);

typedef Task3<T, Q, C> = FutureOr<T> Function(Q argument1, C argument2);
