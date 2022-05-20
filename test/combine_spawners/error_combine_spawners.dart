import 'dart:async';

import 'package:combine/src/combine_info.dart';
import 'package:combine/src/combine_singleton.dart';

Future<CombineInfo> spawnErrorsIsolate() {
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
