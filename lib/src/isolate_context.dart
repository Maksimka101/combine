import 'package:combine/combine.dart';
import 'package:equatable/equatable.dart';

/// [IsolateContext] holds an argument, passed while you spawn `Isolate` and
/// [IsolateMessenger] which is used to communicate with original `Isolate`.
class IsolateContext extends Equatable {
  const IsolateContext({
    required this.argument,
    required this.messenger,
  });

  /// Argument, passed while you spawn `Isolate`.
  final Object? argument;

  /// Messenger which is used to communicate with original `Isolate`.
  final IsolateMessenger messenger;

  @override
  List<Object?> get props => [argument, messenger];
}
