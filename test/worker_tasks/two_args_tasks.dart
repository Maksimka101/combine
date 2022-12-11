Future<int> addTwoNumbers(int first, int second) async => first + second;

Future<int> addThreeNumbers(int first, int second, int third) async {
  return first + second + third;
}

Future<int> addFourNumbers(int first, int second, int third, int fourth) async {
  return first + second + third + fourth;
}

Future<int> addFiveNumbers(
  int first,
  int second,
  int third,
  int fourth,
  int fifth,
) async {
  return first + second + third + fourth + fifth;
}

Future<int> addThreeNumbersNamed(
  int first, {
  required int second,
  int third = 0,
}) async {
  return first + second + third;
}
