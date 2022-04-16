import 'dart:async';
import 'dart:isolate';

import 'package:combine/combine.dart';
import 'package:combine/src/combine_isolate/io_combine_isolate.dart';
import 'package:combine/src/isolate_factory/i_isolate_factory.dart';
import 'package:combine/src/isolate_messenger/io_isolate_messenger.dart';

class IOIsolateFactory extends IIsolateFactory {
  @override
  Future<ICombineIsolate> create(
    IsolateEntryPoint entryPoint,
    Map<String, Object?> arguments, {
    String? debugName,
    bool errorsAreFatal = true,
  }) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn<_IsolateSetup>(
      _runInIsolate,
      _IsolateSetup(
        receivePort.sendPort,
        entryPoint,
        arguments,
      ),
      debugName: debugName ?? "combine_isolate",
      errorsAreFatal: false,
    );

    final receivePortStream = receivePort.asBroadcastStream().cast<Object>();
    final sendPort = await receivePortStream.first as SendPort;

    final isolateMessenger = IOIsolateMessenger(
      sendPort,
      receivePortStream,
    );

    return IOCombineIsolate(isolate, isolateMessenger);
  }

  static void _runInIsolate(_IsolateSetup setup) {
    final receivePort = ReceivePort();
    final isolateMessenger = IOIsolateMessenger(
      setup.sendPort,
      receivePort.asBroadcastStream().cast<Object>(),
    );
    isolateMessenger.send(receivePort.sendPort);

    final isolateContext = IsolateContext(
      arguments: setup.arguments,
      isolateMessenger: isolateMessenger,
    );

    // _IsolateBinding();
    setup.entryPoint(isolateContext);
  }
}

class _IsolateSetup {
  _IsolateSetup(
    this.sendPort,
    this.entryPoint,
    this.arguments,
  );

  final SendPort sendPort;
  final IsolateEntryPoint entryPoint;
  final Map<String, Object?> arguments;
}
