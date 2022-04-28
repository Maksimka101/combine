import 'package:combine/src/combine_isolate/combine_isolate.dart';
import 'package:combine/src/combine_singleton.dart';

Future<CombineIsolate> spawnArgumentsResendIsolate(Object? argument) {
  return Combine().spawn(
    (context) async {
      await Future.delayed(const Duration(milliseconds: 10));
      context.messenger.send(context.argument);
    },
    argument: argument,
  );
}

Future<CombineIsolate> spawnInstantArgumentsResendIsolate(Object? argument) {
  return Combine().spawn(
    (context) async {
      context.messenger
        ..send(context.argument)
        ..messages.listen((event) {
          context.messenger.send(event);
        });
    },
    argument: argument,
  );
}
