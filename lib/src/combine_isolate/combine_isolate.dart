import 'package:combine/combine.dart';

/// [CombineIsolate] is a representation of `Isolate` in which you can use platform channels.
/// So when you create a [CombineIsolate] `Isolate` will be created under the hood except web platform.
///
/// To create a new [CombineIsolate] you just need to call [Combine.spawn].
abstract class CombineIsolate {
  /// Returns a broadcast stream of uncaught errors from the isolate.
  Stream<CombineIsolateError> get errors;

  /// You can use this method method to kill CombineIsolate.
  void kill({int priority = 1});
}

class CombineIsolateError {
  CombineIsolateError(this.error, this.stackTrace);

  final Object error;
  final StackTrace? stackTrace;

  @override
  String toString() {
    return 'CombineIsolateError{error: $error, stackTrace: $stackTrace}';
  }
}
