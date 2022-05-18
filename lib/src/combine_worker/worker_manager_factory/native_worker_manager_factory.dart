import 'dart:io';
import 'dart:math';

import 'package:combine/src/combine_worker/combine_worker_manager.dart';
import 'package:combine/src/combine_worker/effective_worker_factory.dart';
import 'package:combine/src/combine_worker/native_worker_manager.dart';
import 'package:combine/src/combine_worker/worker_manager_factory/combine_worker_manager_factory.dart';
import 'package:flutter/foundation.dart';

class NativeWorkerManagerFactory implements CombineWorkerManagerFactory {
  @override
  CombineWorkerManager create({int? isolatesCount}) {
    return NativeWorkerManager(isolatesCount ?? calculateIsolatesCount());
  }

  @visibleForTesting
  int calculateIsolatesCount() {
    final isolatesCountForTest = testIsolatesCount;
    if (isolatesCountForTest != null) {
      return isolatesCountForTest;
    } else {
      final availableCores = Platform.numberOfProcessors;
      final isolatesCount = max(1, (availableCores / 2).floor());
      return isolatesCount;
    }
  }
}

typedef CombineWorkerManagerFactoryImpl = NativeWorkerManagerFactory;
