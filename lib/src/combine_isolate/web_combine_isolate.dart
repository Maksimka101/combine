import 'dart:async';

import 'package:combine/combine.dart';

class WebCombineIsolate extends CombineIsolate {
  WebCombineIsolate(this.fromIsolate, this.toIsolate);

  final StreamController<Object?> fromIsolate;

  final StreamController<Object?> toIsolate;

  @override
  void kill({int priority = 1}) {
    fromIsolate.close();
    toIsolate.close();
  }
}
