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
    IsolateEntryPoint<T> entryPoint, {
    Map<String, Object?> argumentsMap = const {},
    T? argument,
    bool errorsAreFatal = true,
    String? debugName = "combine_isolate",
  }) async {
    return IOIsolateFactory().create(
      entryPoint,
      argumentsMap: argumentsMap,
      argument: argument,
      debugName: debugName,
      errorsAreFatal: errorsAreFatal,
    );
  }
}

typedef IsolateEntryPoint<T> = void Function(IsolateContext context);
