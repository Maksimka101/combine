import 'dart:developer' as dev;
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:combine/src/binary_messenger_middleware/isolated_method_channel_middleware.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

part 'absent_scheduler_binding.dart';
part 'mock_binary_messenger_service_binding.dart';

class IsolateBinding extends BindingBase
    with
        _AbsentSchedulerBinding,
        ServicesBinding,
        _MockBinaryMessengerServiceBinding {
  @override
  ui.PlatformDispatcher get platformDispatcher {
    throw UnimplementedError();
  }
}
