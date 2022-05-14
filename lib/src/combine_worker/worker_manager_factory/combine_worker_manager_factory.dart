import 'package:combine/src/combine_worker/combine_worker_manager.dart';

abstract class CombineWorkerManagerFactory {
  CombineWorkerManager create({int? isolatesCount});
}
