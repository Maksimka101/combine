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

- [Create and maintain Isolate](#create-and-maintain-isolate)
  - [Create](#create)
  - [Listen for errors](#listen-for-errors)
  - [Kill](#kill)
- [Communicate with Isolate](#communicate-with-isolate)
  - [IsolateContext](#isolatecontext)
  - [Pass arguments](#pass-arguments)
  - [Chat with Isolate](#chat-with-isolate)
- [Dealing with MethodChannels](#dealing-with-methodchannels)
  - [Configuration](#configuration)
  - [Limitations](#limitations)

# Usage

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

### Listen for errors

To listen for errors you can use `CombineIsolate.errors` getter which returns stream with errors
from isolate.

```dart
CombineIsolate combineIsolate;
combineIsolate.errors.listen(print); // Listen for errors.
```

### Kill

To kill CombineIsolate you can use `CombineIsolate.kill` method.

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
To provide argument just pass it to the `spawn` function.

```dart
Combine().spawn(
  (context) {
    final argument = context.argument as String;
    print(argument); // Print: This is my argument
  },
  argument: "This is my argument",
);
```

### Chat with Isolate

To chat with Isolate you can use `IsolateMessenger`. 
It has `messages` getter with stream of messages from Isolate 
and `send` method which sends message to Isolate.

In the crated isolate you can get IsolateMessenger from `IsolateContext.messenger`. 
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

Everything will work fine while you or your plugin just use `MethodChannel.invokeMethod` 
or `BinaryMessenger.send` methods.

However if you or your plugin expect to receive some data from `MethodChannel.setMethodCallHandler`
or `BinaryMessenger.handlePlatformMessage` you may notice that these methods are not working.
This may happen if you didn't send any data to the platform from this Isolate. 

Why? In short the reason is that plugin just sends all messages from known [method] channels
in Main Isolate to the Combine Isolate. However [method] channel becomes known 
when you send anything to it.
The good news is that almost always when you want to receive messages from channel
using `MethodChannel.setMethodCallHandler` or `BinaryMessenger.handlePlatformMessage` methods 
firstly you send some data to this channel so it is very unlikely that you will face this problem.

# Additional information

[Limitation](#limitations) may be fixed by some cool hacks and I'll try to do it later.

Also as you may have already noticed this package is in alpha version. \
So firstly it means that API may be changed. \
Secondly it means that I need to do a lot of things so I need your help. If you like this package
please like and start it! If you have something to say please create an issue! \
I want to know that this package can help someone. It will give me the strength to continue
working on it :)
