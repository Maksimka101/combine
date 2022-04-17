import 'package:combine/combine.dart';

abstract class ICombineIsolate {
  IIsolateMessenger get messenger;

  void kill({int priority = 1});
}
