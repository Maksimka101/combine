import 'dart:isolate';

import 'package:combine/src/combine_isolate/i_combine_isolate.dart';
import 'package:combine/src/isolate_context.dart';
import 'package:combine/src/isolate_factory/io_isolate_factory.dart';

class Combine {
  factory Combine() {
    return _instance ??= Combine._();
  }

  Combine._();

  static Combine? _instance;

  Future<ICombineIsolate> spawn<T>(
    IsolateEntryPoint entryPoint, {
    Map<String, Object?> arguments = const {},
    bool errorsAreFatal = true,
    SendPort? onExit,
    SendPort? onError,
    String? debugName,
  }) async {
    return IOIsolateFactory().create(
      entryPoint,
      arguments,
      debugName: debugName,
    );
  }
}

typedef IsolateEntryPoint = void Function(IsolateContext context);
