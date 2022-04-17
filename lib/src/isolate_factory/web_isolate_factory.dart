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
    // Will be closed by [WebIsolateWrapper.kill].
    // ignore: close_sinks
    final fromIsolate = StreamController<Object?>.broadcast();
    // ignore: close_sinks
    final toIsolate = StreamController<Object?>.broadcast();
    final toIsolateStream = toIsolate.stream;
    final fromIsolateStream = fromIsolate.stream;

    final isolateMessenger = WebInternalIsolateMessenger(
      fromIsolateStream,
      toIsolate.sink,
    );

    // This function run isolated function (IsolateRun).
    // ignore: unawaited_futures
    final context = IsolateContext(
      isolateMessenger: WebInternalIsolateMessenger(
        toIsolateStream,
        fromIsolate.sink,
      ).toIsolateMessenger(),
      argument: argument,
      argumentsMap: argumentsMap ?? {},
    );

    unawaited(_isolateRun(context, entryPoint));

    return WebCombineIsolate(
      isolateMessenger.toIsolateMessenger(),
      fromIsolate,
      toIsolate,
    );
  }

  /// Schedules [isolateRun] to run after [UIIsolateManager] is created.
  ///
  /// Otherwise [IsolateBlocsInitialized] event won't be handled by [UIIsolateManager].
  Future<void> _isolateRun(
    IsolateContext context,
    IsolateEntryPoint isolateRun,
  ) async {
    await Future.delayed(Duration.zero);
    isolateRun(context);
  }
}
