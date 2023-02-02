import 'package:combine/src/combine_info.dart';
import 'package:combine/src/combine_isolate/combine_isolate.dart';
import 'package:combine/src/combine_worker_singleton.dart';
import 'package:combine/src/isolate_factory/effective_isolate_factory.dart';
import 'package:combine/src/isolate_factory/isolate_factory.dart';
import 'package:combine/src/isolate_messenger/isolate_messenger.dart';
import 'package:flutter/services.dart';

/// {@template combine_singleton}
/// [Combine] is used to [spawn] a new [CombineIsolate].
///
/// Take a look at [CombineWorker] if you want to efficiently execute tasks in isolates' pool.
/// {@endtemplate}
class Combine {
  /// {@macro combine_singleton}
  factory Combine() => _instance;
  Combine._();

  /// `late` is used to make this singleton lazy. So it will be initialized
  /// only on first usage.
  static late final _instance = Combine._();

  /// Creates a new [CombineIsolate] which is just a representation of Isolate
  /// that allows to use [MethodChannel]s and [BinaryMessenger]s in it.
  /// So when you create a [CombineIsolate], an Isolate
  /// will be created under the hood. On the web, however,
  /// [entryPoint] will be executed on the main isolate.
  ///
  /// [entryPoint] is a function which will be called in Isolate.
  /// This function may be first-level, as well as a top-level or static.
  /// Also it may use closure variables but with some restrictions:
  ///  - closure variable will be copied (as every variable passed to isolate)
  ///    so it won't be synchronized across Isolates.
  ///  - if you use at least one variable from closure all closure variables
  ///    will be copied to the Isolate due to this
  ///    [issue](https://github.com/dart-lang/sdk/issues/36983).
  ///    It can lead to high memory consumption or event exception because
  ///    some variables may contains native resources.
  ///
  /// Due to above points, I highly recommend you to avoid using closure
  /// variables, until this issue is fixed.
  ///
  /// [debugName] is the Isolate's name for dev tools.
  ///
  /// If [errorsAreFatal] is set to `true` then uncaught exceptions will kill the Isolate.
  ///
  /// Returns [CombineInfo] which holds [CombineIsolate] to control Isolate
  /// and [IsolateMessenger] to communicate with it.
  ///
  /// Example usage:
  /// ```dart
  /// CombineInfo isolateInfo = await Combine().spawn((context) {
  ///   print("Argument from main isolate: ${context.argument}");
  ///
  ///   context.messenger.messages.listen((message) {
  ///     print("Message from main isolate: $message");
  ///     context.messenger.send("Hello from isolate!");
  ///   });
  /// }, argument: 42);
  ///
  /// isolateInfo.messenger
  ///   ..messages.listen((message) {
  ///     print("Message from isolate: $message");
  ///   })
  ///   ..send("Hello from main isolate!");
  ///
  /// // Will print:
  /// // Argument from main isolate: 42
  /// // Message from main isolate: Hello from main isolate!
  /// // Message from isolate: Hello from isolate!
  /// ```
  Future<CombineInfo> spawn<T>(
    IsolateEntryPoint<T> entryPoint, {
    T? argument,
    bool errorsAreFatal = true,
    String? debugName = "combine_isolate",
  }) async {
    return effectiveIsolateFactory.create(
      entryPoint,
      argument: argument,
      errorsAreFatal: errorsAreFatal,
      debugName: debugName,
    );
  }
}
