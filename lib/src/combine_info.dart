import 'package:combine/src/combine_isolate/combine_isolate.dart';
import 'package:combine/src/isolate_messenger/isolate_messenger.dart';

class CombineInfo {
  CombineInfo({required this.messenger, required this.isolate});

  final IsolateMessenger messenger;

  final CombineIsolate isolate;
}
