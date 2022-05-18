import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

@isTest
void testAsyncWidgets(String description, WidgetTesterCallback callback) {
  testWidgets(description, (tester) {
    return tester.runAsync(() {
      return callback(tester);
    });
  });
}
