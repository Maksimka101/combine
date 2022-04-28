import 'dart:async';

import 'package:combine/combine.dart';
import 'package:combine/src/combine_isolate/web_combine_isolate.dart';
import 'package:combine/src/isolate_factory/isolate_factory.dart';
import 'package:combine/src/isolate_messenger/internal_isolate_messenger/web_internal_isolate_messenger.dart';

class IsolateFactoryImpl extends IsolateFactory {
  @override
  Future<CombineIsolate> create<T>(
    IsolateEntryPoint<T> entryPoint, {
    Map<String, Object?>? argumentsMap,
    T? argument,
    String? debugName,
    bool errorsAreFatal = true,
  }) async {
    // Will be closed by [WebCombineIsolate.kill].
    // ignore: close_sinks
    final fromIsolate = StreamController<Object?>();
    // ignore: close_sinks
    final toIsolate = StreamController<Object?>();
    final toIsolateStream = toIsolate.stream.asBroadcastStream();
    final fromIsolateStream = fromIsolate.stream.asBroadcastStream();

    final isolateMessenger = WebInternalIsolateMessenger(
      fromIsolateStream,
      toIsolate.sink,
    );

    final context = IsolateContext(
      messenger: WebInternalIsolateMessenger(
        toIsolateStream,
        fromIsolate.sink,
      ).toIsolateMessenger(),
      argument: argument,
    );

    runZoned(() {
      entryPoint(context);
    });

    return WebCombineIsolate(
      isolateMessenger.toIsolateMessenger(),
      fromIsolate,
      toIsolate,
    );
  }
}
