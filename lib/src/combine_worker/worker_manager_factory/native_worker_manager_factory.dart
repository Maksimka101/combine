import 'dart:io';
import 'dart:math';

import 'package:combine/src/combine_worker/combine_worker_manager.dart';
import 'package:combine/src/combine_worker/native_worker_manager.dart';
import 'package:combine/src/combine_worker/worker_manager_factory/combine_worker_manager_factory.dart';

class NativeWorkerManagerFactory implements CombineWorkerManagerFactory {
  @override
  CombineWorkerManager create({int? isolatesCount}) {
    return NativeWorkerManager(isolatesCount ?? _calculateIsolatesCount());
  }

  int _calculateIsolatesCount() {
    final availableCores = Platform.numberOfProcessors;
    final isolatesCount = max(1, (availableCores / 2).floor());
    return isolatesCount;
  }
}

typedef CombineWorkerManagerFactoryImpl = NativeWorkerManagerFactory;
