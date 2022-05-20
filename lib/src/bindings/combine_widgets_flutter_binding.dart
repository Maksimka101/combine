import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class CombineWidgetsFlutterBinding extends BindingBase
    with
        GestureBinding,
        SchedulerBinding,
        ServicesBinding,
        PaintingBinding,
        SemanticsBinding,
        RendererBinding,
        WidgetsBinding {
  static WidgetsBinding ensureInitialized() {
    try {
      WidgetsBinding.instance;
    } catch (_) {
      CombineWidgetsFlutterBinding();
    }

    return WidgetsBinding.instance;
  }
}
