import 'dart:isolate';

import 'package:combine/combine.dart';
import 'package:combine/src/isolate_messenger/internal_isolate_messenger/internal_isolate_messenger.dart';

class NativeInternalIsolateMessenger extends InternalIsolateMessenger {
  NativeInternalIsolateMessenger(this.sendPort, this.messagesStream);

  final SendPort sendPort;

  @override
  final Stream<Object?> messagesStream;

  @override
  void send(Object? message) {
    if (isClosed) {
      throw IsolateClosedException();
    }
    try {
      sendPort.send(message);
    } on ArgumentError catch (e, st) {
      throw Error.throwWithStackTrace(UnsupportedIsolateArgumentError(e), st);
    }
  }
}
