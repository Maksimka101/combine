import 'package:combine/src/isolate_messenger/isolate_messenger.dart';
import 'package:combine/src/isolate_messenger/isolate_messenger_from_internal.dart';

abstract class InternalIsolateMessenger with ClosableIsolateMessenger {
  /// Stream with messages from isolate.
  Stream<Object?> get messagesStream;

  /// Sends messages to the isolate.
  void send(Object? message);

  IsolateMessenger toIsolateMessenger() => IsolateMessengerFromInternal(this);
}

mixin ClosableIsolateMessenger {
  bool _isClosed = false;
  bool get isClosed => _isClosed;

  void markAsClosed() => _isClosed = true;
}

class IsolateClosedException implements Exception {}
