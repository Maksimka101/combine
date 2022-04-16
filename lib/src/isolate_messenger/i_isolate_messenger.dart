abstract class IIsolateMessenger {
  const IIsolateMessenger();

  /// Stream with messages from isolate.
  Stream<Object> get messagesStream;

  /// Sends messages to the isolate.
  void send(Object message);
}
