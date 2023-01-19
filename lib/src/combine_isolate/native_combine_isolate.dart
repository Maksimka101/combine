import 'dart:isolate';

import 'package:combine/src/combine_isolate/combine_isolate.dart';

class NativeCombineIsolate extends CombineIsolate {
  NativeCombineIsolate(this.onKill, this.errors);

  final void Function({int priority}) onKill;

  @override
  final Stream<CombineIsolateError> errors;

  @override
  void kill({int priority = Isolate.beforeNextEvent}) {
    onKill();
  }
}
