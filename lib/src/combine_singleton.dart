import 'package:combine/src/combine_info.dart';
import 'package:combine/src/combine_isolate/combine_isolate.dart';
import 'package:combine/src/combine_worker_singleton.dart';
import 'package:combine/src/isolate_factory/effective_isolate_factory.dart';
import 'package:combine/src/isolate_factory/isolate_factory.dart';
import 'package:combine/src/isolate_messenger/isolate_messenger.dart';

/// {@template combine_singleton}
/// [Combine] is used to [spawn] a new [CombineIsolate].
///
/// Take a look at [CombineWorker] if you want to efficiently execute tasks in isolates pool.
/// {@endtemplate}
class Combine {
  /// {@macro combine_singleton}
  factory Combine() => _instance;
  Combine._();

  /// `late` is used to make this singleton lazy. So it will be initialized
  /// only while first usage.
  static late final _instance = Combine._();

  /// Creates a new [CombineIsolate] which is just a representation of Isolate.
  /// So when you create a [CombineIsolate] Isolate
  /// will be created under the hood except web platform.
  ///
  /// [entryPoint] is a function which will be called in Isolate.
  /// This function may be a top level function.
  /// Also it may use closure variables but with some restrictions:
  ///  - closure variable will be copped (as every variable passed to isolate)
  ///    so it won't be synchronized across Isolates.
  ///  - if you will use at least one variable from closure all closure variables
  ///    will be copied to the Isolate due to this [issue](https://github.com/dart-lang/sdk/issues/36983).
  ///    It can lead to the high memory consumption or event exception because
  ///    some variables may contains native resources.
  ///
  /// Due to the above points I highly recommend you not to use closure variables
  /// while issue is not fixed.
  ///
  /// [debugName] is an Isolate's name for dev tools.
  ///
  /// If [errorsAreFatal] is set to `true` then uncaught exception will kill Isolate.
  ///
  /// Returns [CombineInfo] which holds [CombineIsolate] to control Isolate
  /// and [IsolateMessenger] to communicate with it.
  ///
  /// Example:
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
