import 'dart:isolate';

import 'package:combine/src/combine_isolate/combine_isolate.dart';
import 'package:combine/src/isolate_messenger/isolate_messenger.dart';

class NativeCombineIsolate extends CombineIsolate {
  NativeCombineIsolate(this._isolate, this.messenger);

  final Isolate _isolate;

  @override
  final IsolateMessenger messenger;

  @override
  Stream<Object?> get errors => _isolate.errors;

  @override
  void setErrorsFatal({required bool errorsAreFatal}) {
    _isolate.setErrorsFatal(errorsAreFatal);
  }

  @override
  void kill({int priority = Isolate.beforeNextEvent}) {
    _isolate.kill(priority: priority);
  }
}
