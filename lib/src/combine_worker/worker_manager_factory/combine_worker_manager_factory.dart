import 'package:combine/src/combine_worker/combine_worker_manager.dart';
import 'package:combine/src/combine_worker_singleton.dart';

abstract class CombineWorkerManagerFactory {
  CombineWorkerManager create({
    int tasksPerIsolate = defaultTasksPerIsolate,
    int? isolatesCount,
  });
}
