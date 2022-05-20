import 'package:combine/combine.dart';

/// [CombineIsolate] is a representation of `Isolate` in which you can use platform channels.
/// So when you create a [CombineIsolate] `Isolate` will be created under the hood except web platform.
///
/// To create a new [CombineIsolate] you just need to call [Combine.spawn].
abstract class CombineIsolate {
  /// You can use this method method to kill CombineIsolate.
  void kill({int priority = 1});
}
