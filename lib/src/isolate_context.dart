import 'package:combine/combine.dart';

/// [IsolateContext] holds an argument, passed while you spawn `Isolate` and
/// [IsolateMessenger] which is used to communicate with original `Isolate`.
class IsolateContext {
  const IsolateContext({
    required this.argument,
    required this.messenger,
  });

  /// Argument, passed while you spawn `Isolate`.
  final Object? argument;

  /// Messenger which is used to communicate with original `Isolate`.
  final IsolateMessenger messenger;
}
