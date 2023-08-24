part of 'isolate_binding.dart';

mixin _MockBinaryMessengerServiceBinding on ServicesBinding {
  @override
  BinaryMessenger createBinaryMessenger() {
    return IsolatedBinaryMessengerMiddleware.instance!
      ..setBinaryMessage(super.createBinaryMessenger());
  }

  @override
  RestorationManager createRestorationManager() {
    throw IsolateBindingInitializationFinished();
  }
}

class IsolateBindingInitializationFinished {}
