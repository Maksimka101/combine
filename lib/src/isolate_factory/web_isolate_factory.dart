import 'dart:async';

import 'package:combine/combine.dart';
import 'package:combine/src/combine_isolate/web_combine_isolate.dart';
import 'package:combine/src/isolate_messenger/internal_isolate_messenger/web_internal_isolate_messenger.dart';

class WebIsolateFactory extends IsolateFactory {
  @override
  Future<CombineInfo> create<T>(
    IsolateEntryPoint<T> entryPoint, {
    Map<String, Object?>? argumentsMap,
    T? argument,
    String? debugName,
    bool errorsAreFatal = true,
    IsolateErrorsHandler? onError,
    ExitHandler? onExit,
  }) async {
    // These controllers will be closed by [WebCombineIsolate.kill].
    final fromIsolate = StreamController.broadcast();
    final toIsolate = StreamController.broadcast();
    final isolateErrors = StreamController<CombineIsolateError>.broadcast();

    final isolateMessenger = WebInternalIsolateMessenger(
      fromIsolate.stream,
      toIsolate.sink,
    );

    final context = IsolateContext(
      messenger: WebInternalIsolateMessenger(
        toIsolate.stream,
        fromIsolate.sink,
      ).toIsolateMessenger(),
      argument: argument,
      isolate: WebCombineIsolate(
        () {},
        isolateErrors.stream,
      ),
    );

    runZonedGuarded(
      () {
        entryPoint(context);
      },
      (error, stackTrace) {
        isolateErrors.add(CombineIsolateError(error, stackTrace));
        onError?.call(error, stackTrace);
      },
    );

    return CombineInfo(
      isolate: WebCombineIsolate(
        () {
          fromIsolate.close();
          toIsolate.close();
          isolateErrors.close();
          isolateMessenger.markAsClosed();
          onExit?.call();
        },
        isolateErrors.stream,
      ),
      messenger: isolateMessenger.toIsolateMessenger(),
    );
  }
}

/// This typedef is used for conditional import.
typedef IsolateFactoryImpl = WebIsolateFactory;
