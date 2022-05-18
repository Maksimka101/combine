import 'package:combine/src/combine_worker/worker_manager_factory/combine_worker_manager_factory.dart';
import 'package:combine/src/combine_worker/worker_manager_factory/native_worker_manager_factory.dart'
    if (dart.library.html) 'package:combine/src/combine_worker/worker_manager_factory/web_worker_manager_factory.dart';
import 'package:flutter/foundation.dart';

@visibleForTesting
void setTestWorkerFactory(CombineWorkerManagerFactory factory) {
  _testWorkerFactory = factory;
}

@visibleForTesting
void clearWorkerFactory() {
  _testWorkerFactory = null;
}

CombineWorkerManagerFactory? _testWorkerFactory;

CombineWorkerManagerFactory get effectiveWorkerFactory {
  return _testWorkerFactory ?? CombineWorkerManagerFactoryImpl();
}

@visibleForTesting
void setTestIsolatesCount(int count) {
  _testIsolatesCount = count;
}

@visibleForTesting
void clearTestIsolatesCount() {
  _testIsolatesCount = null;
}

int? _testIsolatesCount;

int? get testIsolatesCount => _testIsolatesCount;
