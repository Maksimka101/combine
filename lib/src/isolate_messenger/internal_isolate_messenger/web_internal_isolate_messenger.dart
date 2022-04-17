import 'package:combine/src/isolate_messenger/internal_isolate_messenger/internal_isolate_messenger.dart';

class WebInternalIsolateMessenger extends InternalIsolateMessenger {
  WebInternalIsolateMessenger(this.messagesStream, this._sink);

  @override
  final Stream<Object?> messagesStream;
  
  final Sink<Object?> _sink;

  @override
  void send(Object? message) {
    _sink.add(message);
  }
}
