import 'dart:async';
import 'dart:isolate';

import 'package:combine/src/bindings/isolate_bindings/isolate_binding.dart';
import 'package:combine/src/combine_info.dart';
import 'package:combine/src/combine_isolate/native_combine_isolate.dart';
import 'package:combine/src/isolate_context.dart';
import 'package:combine/src/isolate_factory/isolate_factory.dart';
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
    T? argument,
    String? debugName,
    bool errorsAreFatal = true,
  }) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn<_IsolateSetup<T>>(
      _runInIsolate<T>,
      _IsolateSetup<T>(
        receivePort.sendPort,
        entryPoint,
        RootIsolateToken.instance!,
        argument,
      ),
      debugName: debugName,
      errorsAreFatal: errorsAreFatal,
    );

    final receivePortStream = receivePort.asBroadcastStream().cast<Object?>();
    final SendPort sendPort = await receivePortStream.first as dynamic;

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
        isolate,
        () {
          methodChannelMiddleware.dispose();
          isolateMessenger.markAsClosed();
        },
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
    BackgroundIsolateBinaryMessenger.ensureInitialized(setup.isolateToken);
    IsolatedMethodChannelMiddleware(isolateMessenger).initialize();
    try {
      IsolateBinding();
    } catch (_) {} // Isolate binding should throw exception to skip unnecessary initialization.

    final isolateContext = IsolateContext(
      argument: setup.argument,
      messenger: isolateMessenger.toIsolateMessenger(),
      isolate: NativeCombineIsolate(Isolate.current, () {}),
    );
    setup.entryPoint(isolateContext);
  }
}

class _IsolateSetup<T> {
  _IsolateSetup(
    this.sendPort,
    this.entryPoint,
    this.isolateToken,
    this.argument,
  );

  final SendPort sendPort;
  final IsolateEntryPoint<T> entryPoint;
  final RootIsolateToken isolateToken;
  final T? argument;
}

/// This typedef is used for conditional import.
typedef IsolateFactoryImpl = NativeIsolateFactory;
