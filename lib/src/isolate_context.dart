import 'package:combine/combine.dart';
import 'package:equatable/equatable.dart';

class IsolateContext extends Equatable {
  const IsolateContext({
    required this.argument,
    required this.messenger,
  });

  final Object? argument;

  final IsolateMessenger messenger;

  @override
  List<Object?> get props => [argument, messenger];
}
