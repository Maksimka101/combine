import 'dart:isolate';

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
    sendPort.send(message);
  }
}
