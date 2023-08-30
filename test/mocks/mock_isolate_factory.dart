import 'package:combine/src/combine_info.dart';
import 'package:combine/src/combine_isolate/combine_isolate.dart';
import 'package:combine/src/isolate_factory/isolate_factory.dart';
import 'package:flutter/services.dart';
import 'package:mocktail/mocktail.dart';

class MockIsolateFactory extends Mock implements IsolateFactory {}

class FakeCombineIsolate extends Fake implements CombineIsolate {}

class FakeCombineInfo extends Fake implements CombineInfo {}

class FakeRootIsolateToken extends Fake implements RootIsolateToken {}
