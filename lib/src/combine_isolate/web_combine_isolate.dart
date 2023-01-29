import 'package:combine/combine.dart';
import 'package:flutter/material.dart';

class WebCombineIsolate extends CombineIsolate {
  WebCombineIsolate(this.onClose, this.errors);
  final VoidCallback onClose;

  @override
  final Stream<CombineIsolateError> errors;

  @override
  void kill({int priority = 1}) {
    onClose();
  }
}
