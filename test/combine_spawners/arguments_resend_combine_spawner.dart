import 'package:combine/src/combine_isolate/combine_isolate.dart';
import 'package:combine/src/combine_singleton.dart';

Future<CombineIsolate> spawnArgumentsResendIsolate(Object? argument) {
  return Combine().spawn(
    (context) async {
      // TODO(Maksim): don't loose events when launched in web and send called immediately.
      await Future.delayed(const Duration(milliseconds: 10));
      context.messenger.send(context.argument);
    },
    argument: argument,
  );
}
