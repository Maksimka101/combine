/// This is used to generate uniq id
class IdGenerator {
  int _currentId = 0;

  int call() => _currentId++;
}
