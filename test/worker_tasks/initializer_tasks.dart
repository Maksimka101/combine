var _initializerIsCalled = false;

void workerInitializer() {
  _initializerIsCalled = true;
}

bool ensureInitializerIsCalledTask() {
  return _initializerIsCalled;
}
