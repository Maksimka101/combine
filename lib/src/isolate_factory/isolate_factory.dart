import 'package:combine/src/combine_info.dart';
import 'package:combine/src/combine_singleton.dart';

/// It is used to create `Isolate` and setup all necessary stuff
/// which is needed to use method channels.
abstract class IsolateFactory {
  Future<CombineInfo> create<T>(
    IsolateEntryPoint<T> entryPoint, {
    T? argument,
    String? debugName,
    bool errorsAreFatal = true,
    IsolateErrorsHandler? onError,
    ExitHandler? onExit,
  });
}
