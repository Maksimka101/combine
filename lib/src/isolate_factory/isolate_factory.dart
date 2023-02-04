import 'dart:async';

import 'package:combine/combine.dart';
import 'package:flutter/services.dart';

/// It is used to create `Isolate` and setup all necessary stuff
/// which is needed to use method channels.
abstract class IsolateFactory {
  Future<CombineInfo> create<T>(
    IsolateEntryPoint<T> entryPoint, {
    T? argument,
    String? debugName,
    bool errorsAreFatal = true,
    RootIsolateToken? isolateToken,
  });
}

/// Typedef for a function which will be called in Isolate.
typedef IsolateEntryPoint<T> = FutureOr<void> Function(IsolateContext context);
