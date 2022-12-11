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

  final Task2<T, Q, C> task;
  final Q argument;
  final C argument2;

  @override
  FutureOr<T> execute() => task(argument, argument2);
}

class TaskWith3Args<T, Q, C, A> extends ExecutableTask<T> {
  const TaskWith3Args(
    this.task,
    this.argument,
    this.argument2,
    this.argument3,
  );

  final Task3<T, Q, C, A> task;
  final Q argument;
  final C argument2;
  final A argument3;

  @override
  FutureOr<T> execute() => task(argument, argument2, argument3);
}

class TaskWith4Args<T, Q, C, A, B> extends ExecutableTask<T> {
  const TaskWith4Args(
    this.task,
    this.argument,
    this.argument2,
    this.argument3,
    this.argument4,
  );

  final Task4<T, Q, C, A, B> task;
  final Q argument;
  final C argument2;
  final A argument3;
  final B argument4;

  @override
  FutureOr<T> execute() => task(argument, argument2, argument3, argument4);
}

class TaskWith5Args<T, Q, C, A, B, D> extends ExecutableTask<T> {
  const TaskWith5Args(
    this.task,
    this.argument,
    this.argument2,
    this.argument3,
    this.argument4,
    this.argument5,
  );

  final Task5<T, Q, C, A, B, D> task;
  final Q argument;
  final C argument2;
  final A argument3;
  final B argument4;
  final D argument5;

  @override
  FutureOr<T> execute() => task(
        argument,
        argument2,
        argument3,
        argument4,
        argument5,
      );
}

class TaskWithApplyArgs<T> extends ExecutableTask<T> {
  TaskWithApplyArgs(this.task, this.positionalArguments, this.namedArguments);

  final TaskApply task;
  final List<dynamic>? positionalArguments;
  final Map<Symbol, dynamic>? namedArguments;

  @override
  FutureOr<T> execute() {
    return Function.apply(task, positionalArguments, namedArguments);
  }
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
typedef Task2<T, Q, C> = FutureOr<T> Function(Q argument1, C argument2);
typedef Task3<T, Q, C, A> = FutureOr<T> Function(
  Q argument1,
  C argument2,
  A argument3,
);
typedef Task4<T, Q, C, A, B> = FutureOr<T> Function(
  Q argument1,
  C argument2,
  A argument3,
  B argument4,
);
typedef Task5<T, Q, C, A, B, D> = FutureOr<T> Function(
  Q argument1,
  C argument2,
  A argument3,
  B argument4,
  D argument5,
);
typedef TaskApply<T> = Function;
