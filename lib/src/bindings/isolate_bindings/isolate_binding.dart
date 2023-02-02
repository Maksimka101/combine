import 'dart:developer' as dev;
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:combine/src/method_channel_middleware/isolated_method_channel_middleware.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

part 'absent_scheduler_binding.dart';
part 'mock_method_channel_service_binding.dart';
part 'mock_restoration_manager.dart';

class IsolateBinding extends BindingBase
    with
        _AbsentSchedulerBinding,
        ServicesBinding,
        _MockMethodChannelServiceBinding {
  @override
  ui.PlatformDispatcher get platformDispatcher {
    throw UnimplementedError();
  }
}
