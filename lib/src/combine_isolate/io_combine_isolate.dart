import 'dart:isolate';

import 'package:combine/src/combine_isolate/i_combine_isolate.dart';
import 'package:combine/src/isolate_messenger/i_isolate_messenger.dart';

class IOCombineIsolate extends ICombineIsolate {
  IOCombineIsolate(this._isolate, this.messenger);

  final Isolate _isolate;

  @override
  final IIsolateMessenger messenger;

  @override
  void kill({int priority = Isolate.beforeNextEvent}) {
    _isolate.kill(priority: priority);
  }
}
