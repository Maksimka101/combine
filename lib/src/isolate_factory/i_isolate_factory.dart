import 'package:combine/combine.dart';

abstract class IIsolateFactory {
  Future<ICombineIsolate> create<T>(
    IsolateEntryPoint<T> entryPoint, {
    Map<String, Object?>? argumentsMap,
    T? argument,
    String? debugName,
    bool errorsAreFatal = true,
  });
}
