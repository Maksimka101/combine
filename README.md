![Combine logo](assets/combine_logo.png)

<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://pub.dev/packages/combine"><img src="https://img.shields.io/pub/v/combine.svg" alt="Pub"></a>
<a href="https://codecov.io/gh/Maksimka101/combine">
  <img src="https://codecov.io/gh/Maksimka101/combine/branch/master/graph/badge.svg?token=B6UDB81K4Z"/>
</a>


This plugin **Combines** Isolate, MethodChannel and Thread Pool. \
In other words it provides a way to use flutter plugins in `Isolate`
or just work with user friendly API for Isolates.

**Learn more in [this](https://maksimka101.github.io/docusaurus-blog/blog/combine/) article!**

# Features

- Create an Isolate.
- Communicate with Isolate without extra code.
- Use Method Channels in Isolate. 
- Efficiently execute tasks in Isolates pool. 

# Index

- [Short usage example](#short-usage-example)
- [Combine](#combine)
  - [Create and maintain Isolate](#create-and-maintain-isolate)
    - [Create](#create)
    - [Kill](#kill)
  - [Communicate with Isolate](#communicate-with-isolate)
    - [IsolateContext](#isolatecontext)
    - [Pass arguments](#pass-arguments)
    - [Chat with Isolate](#chat-with-isolate)
  - [Dealing with MethodChannels](#dealing-with-methodchannels)
    - [Configuration](#configuration)
- [Combine Worker](#combine-worker)
  - [Initialize worker](#initialize-worker)
  - [Execute tasks](#execute-tasks)
  - [Create a new instance](#create-a-new-instance)
    - [Initialize worker isolates](#initialize-worker-isolates)
  - [Close Worker](#close-worker)
- [Limitations](#limitations)
  - [Method Channel](#method-channel)
  - [Closure variables](#closure-variables)

# Usage

## Short usage example

`Combine` is used to create Isolates. 

```dart
CombineInfo isolateInfo = await Combine().spawn((context) {
  print("Argument from main isolate: ${context.argument}");

  context.messenger.messages.listen((message) {
    print("Message from main isolate: $message");
    context.messenger.send("Hello from isolate!");
  });
}, argument: 42);

isolateInfo.messenger
  ..messages.listen((message) {
    print("Message from isolate: $message");
  })
  ..send("Hello from main isolate!");

// Will print:
// Argument from main isolate: 42
// Message from main isolate: Hello from main isolate!
// Message from isolate: Hello from isolate!
```

`CombineWorker` is a pool of Isolates that efficiently executes tasks in them.

In comparison to Fluter's `compute` method which creates an isolate each time
it is called, Combine Worker creates a pool of isolates and efficiently
reuses them.
```dart
final fibonacciNumber = await CombineWorker().executeWithArg(calculateFibonacci, 42);
print(fibonacciNumber); // 1655801441

int calculateFibonacci(int number) {
  if (number == 1 || number == 2) {
    return 1;
  } else {
    return calculateFibonacci(number - 1) + calculateFibonacci(number - 2);
  }
}
```

## Combine
### Create and maintain Isolate

#### Create

`CombineIsolate` is just a representation of `Isolate` so when you create a CombineIsolate,
an Isolate will be created under the hood. On the web, however, everything will be executed 
on the main isolate.

To create a new CombineIsolate you just need to call `Combine().spawn(entryPointFunction)`.
`entryPointFunction` is a function which will be called in Isolate.

`CombineInfo` will be returned which holds `CombineIsolate` to control `Isolate`
and `IsolateMessenger` to communicate with it.

```dart
CombineInfo combineInfo = await Combine().spawn((context) {
  print("Hello from Isolate!!!");
});
```

#### Kill

You can use `CombineIsolate.kill` method to kill CombineIsolate.

```dart
CombineIsolate combineIsolate;
combineIsolate.kill(); // Kill Isolate.
```

### Communicate with Isolate

#### IsolateContext

Do you remember `context` argument in `entryPointFunction`? Let's take a closer look at it.

`IsolateContext` holds an argument, passed while you spawn Isolate, `IsolateMessenger` 
which is used to communicate with original Isolate and `CombineIsolate` which is 
represents current Isolate.

#### Pass arguments

You can just use variables from closure or
provide argument by passing it to the `spawn` function.

```dart
final argumentFromClosure = "This is argument from main Isolate";
Combine().spawn(
  (context) {
    final argument = context.argument as String;
    print(argument); // Print: This is my argument
    print(argumentFromClosure); // Print: This is argument from main Isolate
  },
  argument: "This is my argument",
);
```

Arguments from closure will be copied to the Isolate. They may be mutable however mutable
variable won't be synchronized so if you change it in main Isolate it won't be changed in 
Combine Isolate.

#### Chat with Isolate

To chat with Isolate you can use `IsolateMessenger`. 
It has `messages` getter with stream of messages from Isolate 
and `send` method which sends message to Isolate.

In the created isolate you can get IsolateMessenger from `IsolateContext.messenger`. 
Another IsolateMessenger can be found in `CombineIsolate`.

```dart
CombineInfo combineInfo = await Combine().spawn((context) {
  context.messenger
    ..messages.listen(
      (event) => print("Message from Main Isolate: $event"),
    )
    ..send("Hello from Combine Isolate!");
});

combineInfo.messenger.messages.listen(
  (event) {
    print("Message from Combine Isolate: $event");
    combineInfo.messenger.send("Hello from Main Isolate!");
  },
);
```

This code will give the following output:
> Message from Combine Isolate: Hello from Combine Isolate! \
> Message from Main Isolate: Hello from Main Isolate!

### Dealing with MethodChannels

#### Configuration

Everything is already configured to work with MethodChannels so you can just use them!

```dart
Combine().spawn((context) async {
  final textFromTestAsset = await rootBundle.loadString("assets/test.txt");
  print("Text from test asset: $textFromTestAsset");
  // Print: Text from test asset: Asset is loaded!
});
```

Explanation:
 - the point it that `rootBundle` uses BinaryMessenger (low level MethodChannel)
 - let's assume that file in `assets/test.txt` exists and contains `Asset is loaded!` text


## Combine Worker
### Initialize worker

To initialize worker you may call `CombineWorker().initialize()` however 
it can be lazily initialized on the first execution so you omit calling this method.

Also this method has `isolatesCount`, `tasksPerIsolate` and `initializer` parameters.
The second parameter is used to set maximum number of tasks that one isolate 
can perform asynchronously. About the `initializer` parameter you can read 
[below](#initialize-worker-isolates).

### Execute tasks

You can execute task with zero, one or two arguments using `execute`, `executeWithArg`
and `executeWith2Args` methods accordingly.

```dart
final helloWorld = await CombineWorker().execute(zeroArgsFunction);
final maksim = await CombineWorker().executeWithArg(oneArgFunction, "Maksim");
final helloArshak  = await CombineWorker().executeWith2Args(
  twoArgsFunction, 
  "Hello", "Arshak!"
);

String zeroArgsFunction() => "Hello, World!";
String oneArgFunction(String str) => str;
String twoArgsFunction(String a, String b) => "$a, $b";
```

If some task will throw an exception, corresponding execute function 
will completes with this exception.

### Create a new instance

If you want to have a few workers with different settings for the separate tasks,
you can create a new worker instance with the `CombineWorker.newInstance` factory.

#### Initialize worker isolates

Sometimes you need to execute some code once worker isolate is created. For example,
to initialize db connection, configure API client, etc. It can be done with the 
`initializer` function parameter for the `CombineWorker.initialize()` method.\
`initializer` is a function that will be executed in each worker isolate during 
their creation. 

### Close Worker

`CombineWorker().close()` method is used to close the current worker.\
`CombineWorker` is a singleton but under the hood it uses a worker manager instance
which can be closed and recreated. It may be useful if you want to cancel 
all running and awaiting tasks (i. e. on user logout).

When worker is closed it completes all tasks with `CombineWorkerClosedException`.\
If you want to wait for remaining tasks set `waitForRemainingTasks` parameter to `true`.
In that case they won't be completed with exception. 

You can call `execute` or `initialize` methods without awaiting for this future.
In that case new worker manager will be created.

## Limitations

### Method Channel

Everything will work fine while `MethodChannel.invokeMethod` 
or `BinaryMessenger.send` methods are used by you or your plugin.

However if `MethodChannel.setMethodCallHandler` or `BinaryMessenger.handlePlatformMessage`
are used by you or your plugin you may notice that these methods are not working.
This may happen if you didn't send any data to the platform from this Isolate. 

Why? In short the reason is that plugin just sends all messages from known [method] channels
in Main Isolate to the Combine Isolate. However [method] channel becomes known 
when you send anything to it.
The good news is when you want to receive messages from channel using
`MethodChannel.setMethodCallHandler` or `BinaryMessenger.handlePlatformMessage` methods 
almost always firstly you send some data to this channel 
so it is very unlikely that you will face this problem.

### Closure variables
Isolate `entryPoint` function for `spawn` method or `task` function for the `execute` methods 
may be a first-level, as well as a static or top-level.

Also, it may use closure variables but with some restrictions:
 - closure variable will be copied (as every variable passed to isolate)
   so it won't be synchronized across Isolates.
 - if you use at least one variable from closure all closure variables
   will be copied to the Isolate due to this [issue](https://github.com/dart-lang/sdk/issues/36983).
   It can lead to high memory consumption or event exception because
   some variables may contain native resources.

Due to the above points, I highly recommend you avoid using closure variables
until this issue is fixed.

