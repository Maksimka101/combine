import 'package:combine/combine.dart';
import 'package:combine/src/isolate_events.dart';
import 'package:combine/src/isolate_messenger/internal_isolate_messenger/i_internal_isolate_messenger.dart';

class IsolateMessengerFromInternal extends IIsolateMessenger {
  IsolateMessengerFromInternal(this._internalIsolateMessenger);

  final IInternalIsolateMessenger _internalIsolateMessenger;

  @override
  Stream<Object?> get messagesStream => _internalIsolateMessenger.messagesStream
      .where((event) => event is! IsolateEvent);

  @override
  void send(Object? message) {
    _internalIsolateMessenger.send(message);
  }
}
