import 'package:combine/combine.dart';
import 'package:equatable/equatable.dart';

class IsolateContext extends Equatable {
  const IsolateContext({
    required this.argumentsMap,
    required this.argument,
    required this.isolateMessenger,
  });

  final Map<String, Object?> argumentsMap;

  final Object? argument;

  final IIsolateMessenger isolateMessenger;

  @override
  List<Object?> get props => [argumentsMap, argument, isolateMessenger];
}
