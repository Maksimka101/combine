import 'package:combine/src/isolate_factory/isolate_factory.dart';
import 'package:combine/src/isolate_factory/native_isolate_factory.dart'
    if (dart.library.js_interop) 'package:combine/src/isolate_factory/web_isolate_factory.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

@visibleForTesting
void setTestIsolateFactory(IsolateFactory isolateFactory) {
  _testIsolateFactory = isolateFactory;
}

@visibleForTesting
void cleanTestIsolateFactory() {
  _testIsolateFactory = null;
}

IsolateFactory? _testIsolateFactory;

/// Returns test isolate factory or it's implementation depending on the platform.
IsolateFactory get effectiveIsolateFactory {
  return _testIsolateFactory ?? IsolateFactoryImpl();
}

RootIsolateToken? getRootIsolateToken({required bool isWeb}) {
  return isWeb ? null : RootIsolateToken.instance;
}
