import 'package:combine/combine.dart';

abstract class IsolateFactory {
  Future<CombineIsolate> create<T>(
    IsolateEntryPoint<T> entryPoint, {
    T? argument,
    String? debugName,
    bool errorsAreFatal = true,
  });
}
