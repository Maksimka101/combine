import 'package:combine/combine.dart';

/// It is used to create `Isolate` and setup all necessary stuff
/// which is needed to use method channels.
abstract class IsolateFactory {
  Future<CombineInfo> create<T>(
    IsolateEntryPoint<T> entryPoint, {
    T? argument,
    String? debugName,
    bool errorsAreFatal = true,
  });
}

/// Typedef for a function which will be called in Isolate.
typedef IsolateEntryPoint<T> = void Function(IsolateContext context);
