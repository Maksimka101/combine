import 'package:combine/src/combine_worker/combine_worker_manager.dart';
import 'package:combine/src/combine_worker/web_worker_manager.dart';
import 'package:combine/src/combine_worker/worker_manager_factory/combine_worker_manager_factory.dart';

class WebWorkerManagerFactory extends CombineWorkerManagerFactory {
  @override
  CombineWorkerManager create({int? isolatesCount}) => WebWorkerManager();
}

typedef WorkerManagerFactoryImpl = WebWorkerManagerFactory;
