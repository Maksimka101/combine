import 'dart:async';
import 'dart:isolate';

import 'package:combine/combine.dart';
import 'package:combine/src/bindings/isolate_bindings/isolate_binding.dart';
import 'package:combine/src/combine_isolate/native_combine_isolate.dart';
import 'package:combine/src/isolate_messenger/internal_isolate_messenger/native_internal_isolate_messenger.dart';
import 'package:combine/src/method_channel_middleware/isolated_method_channel_middleware.dart';
import 'package:combine/src/method_channel_middleware/ui_method_channel_middleware.dart';
import 'package:flutter/services.dart';

/// It is used to create [Isolate] and setup all necessary stuff
/// which is needed to use method channels.
class NativeIsolateFactory extends IsolateFactory {
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
    final receivePort = ReceivePort();
    final errorPort = ReceivePort();
    final exitPort = ReceivePort();

    final receivePortStream = receivePort.asBroadcastStream().cast<Object?>();
    final errorPortStream = errorPort //
        .asBroadcastStream()
        .map(_mapErrorFromIsolate);
    final onErrorListenerSubscription = onError == null
        ? null
        : errorPortStream
            .listen((event) => onError(event.error, event.stackTrace));

    final isolate = await Isolate.spawn<_IsolateSetup<T>>(
      _runInIsolate<T>,
      _IsolateSetup<T>(
        receivePort.sendPort,
        entryPoint,
        argumentsMap,
        argument,
      ),
      debugName: debugName,
      errorsAreFatal: errorsAreFatal,
      onError: errorPort.sendPort,
      onExit: exitPort.sendPort,
    );

    unawaited(exitPort.first.then((_) => onExit?.call()));
    final sendPort = await receivePortStream.first as SendPort;
    final isolateMessenger = NativeInternalIsolateMessenger(
      sendPort,
      receivePortStream,
    );

    final methodChannelMiddleware = UIMethodChannelMiddleware(
      ServicesBinding.instance.defaultBinaryMessenger,
      isolateMessenger,
    )..initialize();
    return CombineInfo(
      isolate: NativeCombineIsolate(
        ({priority = Isolate.beforeNextEvent}) {
          isolate.kill(priority: priority);
          methodChannelMiddleware.dispose();
          onErrorListenerSubscription?.cancel();
          isolateMessenger.markAsClosed();
        },
        errorPortStream,
      ),
      messenger: isolateMessenger.toIsolateMessenger(),
    );
  }

  static void _runInIsolate<T>(_IsolateSetup<T> setup) {
    final receivePort = ReceivePort();
    final isolateMessenger = NativeInternalIsolateMessenger(
      setup.sendPort,
      receivePort.asBroadcastStream().cast<Object?>(),
    );
    isolateMessenger.send(receivePort.sendPort);
    final isolate = Isolate.current;
    final errorPort = ReceivePort();
    isolate.addErrorListener(errorPort.sendPort);
    final errorPortStream = errorPort //
        .asBroadcastStream()
        .map(_mapErrorFromIsolate);

    final isolateContext = IsolateContext(
      argument: setup.argument,
      messenger: isolateMessenger.toIsolateMessenger(),
      isolate: NativeCombineIsolate(
        ({priority = Isolate.beforeNextEvent}) {
          isolate.kill();
        },
        errorPortStream,
      ),
    );

    IsolatedMethodChannelMiddleware(isolateMessenger).initialize();
    IsolateBinding();
    setup.entryPoint(isolateContext);
  }

  static CombineIsolateError _mapErrorFromIsolate(Object? event) {
    if (event is List && event.length == 2) {
      final errorDescription = event[0];
      final stackTraceDescription = event[1];
      StackTrace? stackTrace;
      try {
        stackTrace = StackTrace.fromString(stackTraceDescription);
      } catch (_) {}
      return CombineIsolateError(errorDescription, stackTrace);
    }
    return event is RemoteError
        ? CombineIsolateError(event, event.stackTrace)
        : CombineIsolateError(event ?? 'Unknown exception', null);
  }
}

class _IsolateSetup<T> {
  _IsolateSetup(
    this.sendPort,
    this.entryPoint,
    this.argumentsMap,
    this.argument,
  );

  final SendPort sendPort;
  final IsolateEntryPoint<T> entryPoint;
  final Map<String, Object?>? argumentsMap;
  final T? argument;
}

/// This typedef is used for conditional import.
typedef IsolateFactoryImpl = NativeIsolateFactory;
