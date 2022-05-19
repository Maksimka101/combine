import 'dart:io';
import 'dart:math';

import 'package:combine/src/combine_worker/combine_worker_manager.dart';
import 'package:combine/src/combine_worker/effective_worker_factory.dart';
import 'package:combine/src/combine_worker/native_worker_manager.dart';
import 'package:combine/src/combine_worker/worker_manager_factory/combine_worker_manager_factory.dart';
import 'package:combine/src/combine_worker_singleton.dart';
import 'package:flutter/foundation.dart';

class NativeWorkerManagerFactory implements CombineWorkerManagerFactory {
  @override
  CombineWorkerManager create({
    int tasksPerIsolate = defaultTasksPerIsolate,
    int? isolatesCount,
  }) {
    return NativeWorkerManager(
      tasksPerIsolate: tasksPerIsolate,
      isolatesCount: isolatesCount ?? calculateIsolatesCount(),
    );
  }

  @visibleForTesting
  int calculateIsolatesCount() {
    final isolatesCountForTest = testIsolatesCount;
    if (isolatesCountForTest != null) {
      return isolatesCountForTest;
    } else {
      final numberOfProcessors = Platform.numberOfProcessors;
      final isolatesCount = max(1, (numberOfProcessors / 2).floor());
      return isolatesCount;
    }
  }
}

typedef CombineWorkerManagerFactoryImpl = NativeWorkerManagerFactory;
