import 'package:combine/combine.dart';
import 'package:combine/src/isolate_messenger/internal_isolate_messenger/internal_isolate_messenger.dart';

/// [IsolateMessenger] is used to chat with `Isolate`.
/// It has [messages] getter with stream of messages from `Isolate`
/// and [send] method which sends message to `Isolate`.
abstract class IsolateMessenger {
  const IsolateMessenger();

  /// Stream with messages from `Isolate`.
  Stream<Object?> get messages;

  /// Sends messages to `Isolate`.
  ///
  /// Throws [UnsupportedIsolateArgumentError] and [IsolateClosedException].
  void send(Object? message);
}
