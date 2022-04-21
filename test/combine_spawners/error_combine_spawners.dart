import 'dart:async';

import 'package:combine/src/combine_isolate/combine_isolate.dart';
import 'package:combine/src/combine_singleton.dart';

Future<CombineIsolate> spawnErrorsIsolate() {
  return Combine().spawn(
    (context) async {
      final errorCompleter = Completer();

      context.messenger.messages.listen((event) {
        errorCompleter
            .completeError(Exception("Exception in combine isolate."));
      });

      await errorCompleter.future;
    },
    errorsAreFatal: false,
  );
}
