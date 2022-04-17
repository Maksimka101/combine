import 'dart:isolate';

import 'package:combine/src/isolate_messenger/i_isolate_messenger.dart';
import 'package:combine/src/isolate_messenger/internal_isolate_messenger/i_internal_isolate_messenger.dart';
import 'package:combine/src/isolate_messenger/isolate_messenger_from_internal.dart';

class IOInternalIsolateMessenger extends IInternalIsolateMessenger {
  IOInternalIsolateMessenger(this.sendPort, this.messagesStream);

  final SendPort sendPort;

  @override
  final Stream<Object?> messagesStream;

  @override
  void send(Object? message) {
    sendPort.send(message);
  }

  IIsolateMessenger toIsolateMessenger() => IsolateMessengerFromInternal(this);
}
