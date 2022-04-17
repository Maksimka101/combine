part of 'isolate_binding.dart';

mixin _MockMethodChannelServiceBinding on ServicesBinding {
  @override
  BinaryMessenger createBinaryMessenger() {
    final methodChannelMiddleware = IsolatedMethodChannelMiddleware.instance;
    if (methodChannelMiddleware == null) {
      throw Exception();
    } else {
      return methodChannelMiddleware
        ..setBinaryMessage(super.createBinaryMessenger());
    }
  }
}
