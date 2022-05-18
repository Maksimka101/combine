import 'package:combine/src/combine_info.dart';
import 'package:combine/src/combine_isolate/combine_isolate.dart';
import 'package:combine/src/isolate_factory/effective_isolate_factory.dart';
import 'package:combine/src/isolate_factory/isolate_factory.dart';
import 'package:combine/src/isolate_messenger/isolate_messenger.dart';

/// [Combine] is used to [spawn] a new [CombineIsolate].
class Combine {
  factory Combine() => _instance;
  Combine._();

  /// `late` is used to make this singleton lazy. So it will be initialized
  /// only while first usage.
  static late final _instance = Combine._();

  /// Create a new [CombineIsolate] which is just a representation of `Isolate`.
  /// So when you create a [CombineIsolate] `Isolate`
  /// will be created under the hood except web platform.
  ///
  /// [entryPoint] is a function which will be called in Isolate.
  ///
  /// Returns [CombineInfo] which holds [CombineIsolate] to control `Isolate`
  /// and [IsolateMessenger] to communicate with it.
  Future<CombineInfo> spawn<T>(
    IsolateEntryPoint<T> entryPoint, {
    T? argument,
    bool errorsAreFatal = true,
    String? debugName = "combine_isolate",
  }) async {
    return effectiveIsolateFactory.create(
      entryPoint,
      argument: argument,
      errorsAreFatal: errorsAreFatal,
      debugName: debugName,
    );
  }
}
