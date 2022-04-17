import 'package:combine/combine.dart';

abstract class CombineIsolate {
  IsolateMessenger get messenger;

  Stream<Object?> get errors;

  void setErrorsFatal({required bool errorsAreFatal});

  void kill({int priority = 1});
}
