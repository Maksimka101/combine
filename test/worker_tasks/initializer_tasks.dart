var _initializerIsCalled = false;
var _initializerCallsCount = 0;

void workerInitializer() {
  _initializerIsCalled = true;
  _initializerCallsCount++;
}

bool initializerIsCalledTask() {
  return _initializerIsCalled;
}

bool ensureInitializerIsCalledOnceTask() {
  return _initializerCallsCount == 1;
}
