import 'dart:async';

import 'package:combine/src/combine_info.dart';
import 'package:combine/src/combine_isolate/web_combine_isolate.dart';
import 'package:combine/src/isolate_context.dart';
import 'package:combine/src/isolate_factory/isolate_factory.dart';
import 'package:combine/src/isolate_messenger/internal_isolate_messenger/web_internal_isolate_messenger.dart';

class WebIsolateFactory extends IsolateFactory {
  @override
  Future<CombineInfo> create<T>(
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
      isolate: WebCombineIsolate(() {}),
    );

    runZoned(() {
      entryPoint(context);
    });

    return CombineInfo(
      isolate: WebCombineIsolate(() {
        fromIsolate.close();
        toIsolate.close();
        isolateMessenger.markAsClosed();
      }),
      messenger: isolateMessenger.toIsolateMessenger(),
    );
  }
}

/// This typedef is used for conditional import.
typedef IsolateFactoryImpl = WebIsolateFactory;
