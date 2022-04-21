import 'dart:isolate';

import 'package:combine/src/combine_isolate/combine_isolate.dart';
import 'package:combine/src/isolate_messenger/isolate_messenger.dart';
import 'package:flutter/foundation.dart';

class NativeCombineIsolate extends CombineIsolate {
  NativeCombineIsolate(this._isolate, this.messenger, this.onKill);

  final Isolate _isolate;
  final VoidCallback onKill;

  @override
  final IsolateMessenger messenger;

  @override
  void kill({int priority = Isolate.beforeNextEvent}) {
    _isolate.kill(priority: priority);
    onKill();
  }
}
