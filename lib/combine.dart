/// A Flutter package which allows you to work with MethodChannels in Isolate
/// and provides simplified Isolate and Thread Pool API.
library combine;

export 'src/combine_info.dart';
export 'src/combine_isolate/combine_isolate.dart';
export 'src/combine_singleton.dart';
export 'src/combine_worker/combine_worker_impl.dart';
export 'src/combine_worker/combine_worker_manager.dart';
export 'src/combine_worker/effective_worker_factory.dart';
export 'src/combine_worker/native_worker_manager.dart';
export 'src/combine_worker/tasks.dart';
export 'src/combine_worker/web_worker_manager.dart';
export 'src/combine_worker/worker_manager_factory/combine_worker_manager_factory.dart';
export 'src/combine_worker/worker_manager_factory/native_worker_manager_factory.dart'
    if (dart.library.js_interop) 'src/combine_worker/worker_manager_factory/web_worker_manager_factory.dart'
    hide CombineWorkerManagerFactoryImpl;
export 'src/combine_worker_singleton.dart';
export 'src/isolate_context.dart';
export 'src/isolate_factory/effective_isolate_factory.dart';
export 'src/isolate_factory/isolate_factory.dart';
export 'src/isolate_factory/native_isolate_factory.dart'
    if (dart.library.js_interop) 'src/isolate_factory/web_isolate_factory.dart'
    hide IsolateFactoryImpl;
export 'src/isolate_messenger/isolate_messenger.dart';
