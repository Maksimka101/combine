import 'package:combine/combine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _counter = 0;
  var _loadedAssetString = "No assets loaded";
  final _calculatedFibonacciValues = <int>[];
  Object? _calculateFibonacciError;
  CombineInfo? _counterIsolate;
  CombineInfo? _assetsIsolate;

  @override
  void initState() {
    super.initState();
    _createCounterIsolate();
    _createAssetsIsolate();
  }

  Future<void> _createCounterIsolate() async {
    final isolate = await Combine().spawn(
      (context) async {
        final sp = await SharedPreferences.getInstance();
        final messenger = context.messenger;
        var counter = sp.getInt('counter') ?? 0;
        messenger.messages.listen((event) {
          if (event == "increment") {
            messenger.send(++counter);
          } else if (event == "decrement") {
            messenger.send(--counter);
          } else if (event == "initial") {
            messenger.send(counter);
          }
          sp.setInt("counter", counter);
        });
      },
      debugName: "counter",
    );

    _counterIsolate = isolate;
    setState(() {});
    isolate.messenger
      ..messages.listen((event) {
        if (event is int) {
          _counter = event;
          setState(() {});
        }
      })
      ..send('initial');
  }

  Future<void> _createAssetsIsolate() async {
    final isolate = await Combine().spawn<String>(
      (context) {
        final messenger = context.messenger;

        messenger.messages.listen((event) async {
          if (event is String) {
            try {
              final assetString = await rootBundle.loadString(event);
              messenger.send(assetString);
            } catch (e, st) {
              messenger.send("Failed to load asset\nError: $e\n$st");
              debugPrint(e.toString());
            }
          }
        });
      },
      debugName: "assets",
    );

    _assetsIsolate = isolate;
    setState(() {});
    isolate.messenger.messages.listen((event) {
      if (event is String) {
        _loadedAssetString = event;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Combine"),
      ),
      body: ListView(
        children: [
          if (_counterIsolate == null || _assetsIsolate == null)
            const Text("Isolate is creating")
          else ...[
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 10),
              child: Text(
                'This counter is incremented and decremented in a Isolate and stored in the SharedPreferences.\n'
                'This example shows how to work with the MethodChannels or packages that use them in a Isolate.',
              ),
            ),
            ListTile(
              title: Text("Counter: $_counter"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _onDecrementCounter,
                    icon: const Icon(Icons.remove),
                  ),
                  IconButton(
                    onPressed: _onIncrementCounter,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 10),
              child: Text(
                'This example shows how to work with the BinaryMessenger or packages that use it in a Isolate.',
              ),
            ),
            ListTile(
              title: const Text("Loaded asset:"),
              subtitle: Text(_loadedAssetString),
              onTap: _onLoadAsset,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 10),
              child: Text(
                'This example shows how to work the CombineWorker and catch errors in it.',
              ),
            ),
            ListTile(
              title: const Text("Calculate fibonacci numbers"),
              subtitle: const Text(
                "from zero to the counter number using CombineWorker",
              ),
              onTap: _onCalculateAllFibNumbers,
            ),
            if (_calculatedFibonacciValues.isNotEmpty)
              ListTile(
                title: const Text("Last 10 fibonacci numbers"),
                subtitle: Text(_calculatedFibonacciValues.take(10).join(", ")),
              ),
            if (_calculateFibonacciError != null)
              ListTile(
                title: const Text("Error from calculate fibonacci worker"),
                subtitle: Text(_calculateFibonacciError.toString()),
              ),
          ]
        ],
      ),
    );
  }

  void _onIncrementCounter() {
    _counterIsolate?.messenger.send("increment");
  }

  void _onDecrementCounter() {
    _counterIsolate?.messenger.send("decrement");
  }

  void _onLoadAsset() {
    _assetsIsolate?.messenger.send("assets/test.txt");
    _loadedAssetString = "Loading in progress";
    setState(() {});
  }

  void _onCalculateAllFibNumbers() {
    _calculatedFibonacciValues.clear();
    for (var i = 0; i < _counter; i++) {
      CombineWorker().executeWithArg(calculateFibonacci, i).then(
        (value) {
          _calculatedFibonacciValues.insert(0, value);
          setState(() {});
        },
      ).onError((error, stackTrace) {
        setState(() => _calculateFibonacciError = error);
      });
    }
  }
}

int calculateFibonacci(int number) {
  if (number == 16) {
    throw UnsupportedError("Can't calculate value for $number");
  }
  return _calculateFibonacci(number);
}

int _calculateFibonacci(int number) {
  if (number <= 0) {
    return 0;
  } else if (number == 1 || number == 2) {
    return 1;
  } else {
    return _calculateFibonacci(number - 1) + _calculateFibonacci(number - 2);
  }
}
