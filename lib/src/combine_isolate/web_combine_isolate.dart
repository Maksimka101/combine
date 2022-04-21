import 'dart:async';

import 'package:combine/combine.dart';

class WebCombineIsolate extends CombineIsolate {
  WebCombineIsolate(this.messenger, this.fromIsolate, this.toIsolate);

  final StreamController<Object?> fromIsolate;

  final StreamController<Object?> toIsolate;

  @override
  final IsolateMessenger messenger;

  @override
  void kill({int priority = 1}) {
    fromIsolate.close();
    toIsolate.close();
  }
}
