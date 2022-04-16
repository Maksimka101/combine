import 'dart:isolate';

import 'package:combine/src/isolate_messenger/i_isolate_messenger.dart';

class IOIsolateMessenger extends IIsolateMessenger {
  IOIsolateMessenger(this.sendPort, this.messagesStream);

  final SendPort sendPort;

  @override
  final Stream<Object> messagesStream;

  @override
  void send(Object message) {
    sendPort.send(message);
  }
}
