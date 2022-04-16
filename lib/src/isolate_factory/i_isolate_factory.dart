import 'package:combine/combine.dart';

abstract class IIsolateFactory {
  Future<ICombineIsolate> create(
    IsolateEntryPoint entryPoint,
    Map<String, Object?> arguments, {
    String? debugName,
    bool errorsAreFatal = true,
  });
}
