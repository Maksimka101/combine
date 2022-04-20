part of 'isolate_binding.dart';

mixin _MockMethodChannelServiceBinding on ServicesBinding {
  @override
  BinaryMessenger createBinaryMessenger() {
    return IsolatedMethodChannelMiddleware.instance!
      ..setBinaryMessage(super.createBinaryMessenger());
  }
}
