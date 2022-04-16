import 'package:combine/combine.dart';

class IsolateContext {
  const IsolateContext({
    required this.arguments,
    required this.isolateMessenger,
  });

  final Map<String, Object?> arguments;

  final IIsolateMessenger isolateMessenger;
}
