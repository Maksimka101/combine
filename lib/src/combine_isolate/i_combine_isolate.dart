import 'package:combine/combine.dart';

abstract class ICombineIsolate {
  IIsolateMessenger get isolateMessenger;

  void kill({int priority = 1});
}
