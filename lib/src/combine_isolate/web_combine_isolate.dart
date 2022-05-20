import 'package:combine/combine.dart';
import 'package:flutter/material.dart';

class WebCombineIsolate extends CombineIsolate {
  WebCombineIsolate(this.onClose);

  final VoidCallback onClose;

  @override
  void kill({int priority = 1}) {
    onClose();
  }
}
