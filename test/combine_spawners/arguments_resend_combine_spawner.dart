import 'package:combine/src/combine_info.dart';
import 'package:combine/src/combine_singleton.dart';

Future<CombineInfo> spawnArgumentsResendIsolate(Object? argument) {
  return Combine().spawn(
    (context) async {
      await Future.delayed(const Duration(milliseconds: 10));
      context.messenger.send(context.argument);
    },
    argument: argument,
  );
}

Future<CombineInfo> spawnInstantArgumentsResendIsolate(Object? argument) {
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
