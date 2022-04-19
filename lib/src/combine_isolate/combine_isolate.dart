import 'package:combine/combine.dart';

/// [CombineIsolate] is just a representation of `Isolate` so when you create a
/// [CombineIsolate] `Isolate` will be created under the hood except web platform.
///
/// To create a new [CombineIsolate] you just need to call [Combine.spawn].
abstract class CombineIsolate {
  IsolateMessenger get messenger;

  /// Use this method to listen to errors.
  ///
  /// Returns stream with errors from isolate.
  Stream<Object?> get errors;

  void setErrorsFatal({required bool errorsAreFatal});

  /// You can use this method method to kill CombineIsolate.
  void kill({int priority = 1});
}
