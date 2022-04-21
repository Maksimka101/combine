import 'package:combine/combine.dart';

/// [CombineIsolate] is just a representation of `Isolate` so when you create a
/// [CombineIsolate] `Isolate` will be created under the hood except web platform.
///
/// To create a new [CombineIsolate] you just need to call [Combine.spawn].
abstract class CombineIsolate {
  /// Messenger which is used to send message to the isolate listen for messages from it.
  IsolateMessenger get messenger;

  /// You can use this method method to kill CombineIsolate.
  void kill({int priority = 1});
}
