import 'package:combine/src/combine_isolate/combine_isolate.dart';
import 'package:combine/src/isolate_context.dart';
import 'package:combine/src/isolate_factory/native_isolate_factory.dart'
    if (dart.library.html) 'package:combine/src/isolate_factory/web_isolate_factory.dart';

class Combine {
  factory Combine() {
    return _instance;
  }

  Combine._();

  static late final _instance = Combine._();

  final _isolateFactory = IsolateFactoryImpl();

  Future<CombineIsolate> spawn<T>(
    IsolateEntryPoint<T> entryPoint, {
    T? argument,
    bool errorsAreFatal = true,
    String? debugName = "combine_isolate",
  }) async {
    return _isolateFactory.create(
      entryPoint,
      argument: argument,
      debugName: debugName,
      errorsAreFatal: errorsAreFatal,
    );
  }
}

typedef IsolateEntryPoint<T> = void Function(IsolateContext context);
