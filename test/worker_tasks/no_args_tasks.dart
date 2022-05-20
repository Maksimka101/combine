Future<void> voidEmptyTask() async {}

const constVoidTaskValue = "some val";
Future<String> constTask() async => constVoidTaskValue;

Future<Never> throwExceptionTask() async => throw Exception();

Future<String> delayedConstTask() async {
  await Future.delayed(const Duration(milliseconds: 200));
  return constVoidTaskValue;
}
