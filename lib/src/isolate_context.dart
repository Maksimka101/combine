import 'package:combine/combine.dart';

/// [IsolateContext] holds an argument, passed while you spawn `Isolate`,
/// [IsolateMessenger] which is used to communicate with original `Isolate`
/// and [CombineIsolate] which is represents current `Isolate`.
class IsolateContext {
  const IsolateContext({
    required this.argument,
    required this.messenger,
    required this.isolate,
  });

  /// Argument, passed while you spawn `Isolate`.
  final Object? argument;

  /// Messenger which is used to communicate with original `Isolate`.
  final IsolateMessenger messenger;

  final CombineIsolate isolate;
}
