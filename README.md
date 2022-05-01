<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://pub.dev/packages/combine"><img src="https://img.shields.io/pub/v/combine.svg" alt="Pub"></a>
<a href="https://codecov.io/gh/Maksimka101/combine">
  <img src="https://codecov.io/gh/Maksimka101/combine/branch/master/graph/badge.svg?token=B6UDB81K4Z"/>
</a>


This plugin **Combines** Isolate and MethodChannel. \
In other words it provides a way to use flutter plugins in `Isolate`
or just work with user friendly API for Isolate.

# Features

- Create an Isolate.
- Communicate with Isolate without extra code.
- Use Method Channels in Isolate. 
- Supports all flutter platforms.

❌️ It doesn't create Isolate alternative (aka service worker) in web.
So all code will work in single (main) Isolate.

# Index

- [Short usage example](#short-usage-example)
- [Create and maintain Isolate](#create-and-maintain-isolate)
  - [Create](#create)
  - [Listen to errors](#listen-to-errors)
  - [Kill](#kill)
- [Communicate with Isolate](#communicate-with-isolate)
  - [IsolateContext](#isolatecontext)
  - [Pass arguments](#pass-arguments)
  - [Chat with Isolate](#chat-with-isolate)
- [Dealing with MethodChannels](#dealing-with-methodchannels)
  - [Configuration](#configuration)
  - [Limitations](#limitations)

# Usage

## Short usage example

```dart
CombineIsolate isolate = await Combine().spawn((context) {
  print("Argument from main isolate: ${context.argument}");

  context.messenger.messages.listen((message) {
    print("Message from main isolate: $message");
    context.messenger.send("Hello from isolate!");
  });
}, argument: 42);

isolate.messenger
  ..messages.listen((message) {
    print("Message from isolate: $message");
  })
  ..send("Hello from main isolate!");

// Will print:
// Argument from main isolate: 42
// Message from main isolate: Hello from main isolate!
// Message from isolate: Hello from isolate!
```

## Create and maintain Isolate

### Create

`CombineIsolate` is just a representation of `Isolate` so when you create a CombineIsolate
Isolate will be created under the hood except web platform.

To create a new CombineIsolate you just need to call `Combine().spawn(entryPointFunction)`.
`entryPointFunction` is a function which will be called in Isolate.

```dart
CombineIsolate combineIsolate = await Combine().spawn((context) {
  print("Hello from Isolate!!!");
});
```

### Listen to errors

To listen to errors you can use `CombineIsolate.errors` getter which 
returns stream with errors from isolate.

```dart
CombineIsolate combineIsolate;
combineIsolate.errors.listen(print); // Listen for errors.
```

### Kill

You can use `CombineIsolate.kill` method to kill CombineIsolate.

```dart
CombineIsolate combineIsolate;
combineIsolate.kill(); // Kill Isolate.
```

## Communicate with Isolate

### IsolateContext

Do you remember `context` argument in `entryPointFunction`? Let's take a closer look at it.

`IsolateContext` holds an argument, passed while you spawn Isolate and `IsolateMessenger` 
which is used to communicate with original Isolate.

### Pass arguments

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

### Chat with Isolate

To chat with Isolate you can use `IsolateMessenger`. 
It has `messages` getter with stream of messages from Isolate 
and `send` method which sends message to Isolate.

In the created isolate you can get IsolateMessenger from `IsolateContext.messenger`. 
Another IsolateMessenger can be found in `CombineIsolate`.

```dart
CombineIsolate combineIsolate = await Combine().spawn((context) {
  context.messenger
    ..messages.listen(
      (event) => print("Message from Main Isolate: $event"),
    )
    ..send("Hello from Combine Isolate!");
});

combineIsolate.messenger.messages.listen(
  (event) {
    print("Message from Combine Isolate: $event");
    combineIsolate.messenger.send("Hello from Main Isolate!");
  },
);
```

This code will give the following output:
> Message from Combine Isolate: Hello from Combine Isolate! \
> Message from Main Isolate: Hello from Main Isolate!

## Dealing with MethodChannels

### Configuration

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

### Limitations

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

# Additional information

[Limitation](#limitations) may be fixed by some cool hacks and I'll try to do it later.

Also as you might have noticed this package is in beta version. \
So firstly it means that API may be changed. \
Secondly it means that I need to do a lot of things so I need your help. If you like this package
please like and star it! If you have something to say please create an issue! \
I want to know that this package can help someone. It will give me the strength to continue
working on it :)
