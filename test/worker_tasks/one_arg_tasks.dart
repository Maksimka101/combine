import 'dart:developer';

Future<void> voidOneArgTask(_) async {}

Future<String> valueTask(String value) async => value;

Future<int> incrementTask(int value) async => value + 1;

Future<UserTag> unsupportedArgumentTask(_) async {
  return UserTag("");
}
