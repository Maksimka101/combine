import 'package:combine/src/combine_worker/combine_worker_manager.dart';
import 'package:combine/src/combine_worker/tasks.dart';

class WebWorkerManager extends CombineWorkerManager {
  @override
  Future<void> initialize() async {}

  @override
  Future<T> execute<T>(ExecutableTask<T> task) async {
    await null;
    return task.execute();
  }
}
