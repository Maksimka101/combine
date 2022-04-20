import 'dart:async';

import 'package:combine/src/combine_isolate/combine_isolate.dart';
import 'package:combine/src/isolate_factory/isolate_factory.dart';

Future<CombineIsolate> spawnErrorsIsolate(IsolateFactory factory) {
  return factory.create(
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
