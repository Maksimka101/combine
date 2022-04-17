import 'package:combine/combine.dart';
import 'package:combine/src/isolate_events.dart';
import 'package:combine/src/isolate_messenger/internal_isolate_messenger/internal_isolate_messenger.dart';

class IsolateMessengerFromInternal extends IsolateMessenger {
  IsolateMessengerFromInternal(this._internalIsolateMessenger);

  final InternalIsolateMessenger _internalIsolateMessenger;

  @override
  Stream<Object?> get messages => _internalIsolateMessenger.messagesStream
      .where((event) => event is! IsolateEvent);

  @override
  void send(Object? message) {
    _internalIsolateMessenger.send(message);
  }
}
