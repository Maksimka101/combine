bool? _flag;
const setFlagDelay = Duration(milliseconds: 100);
Future<void> setWaitAndRemoveFlag() async {
  _flag = true;
  await Future.delayed(setFlagDelay);
  _flag = false;
}

Future<bool?> getFlagValue() async => _flag;
