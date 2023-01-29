import 'package:combine/combine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      (context) {
        final messenger = context.messenger;
        var counter = 0;
        messenger.messages.listen((event) {
          if (event == "increment") {
            messenger.send(++counter);
          }
        });
      },
      debugName: "counter",
    );

    _counterIsolate = isolate;
    setState(() {});
    isolate.messenger.messages.listen((event) {
      if (event is int) {
        _counter = event;
        setState(() {});
      }
    });
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
            } catch (e) {
              messenger.send("Failed to load asset\nError: $e");
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
            ListTile(
              title: Text("Counter: $_counter"),
              trailing: IconButton(
                onPressed: _onIncrementCounter,
                icon: const Icon(Icons.add),
              ),
            ),
            ListTile(
              title: const Text("Loaded asset text:"),
              subtitle: Text(_loadedAssetString),
              onTap: _onLoadAsset,
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
  if (number == 0) {
    return 0;
  } else if (number == 1 || number == 2) {
    return 1;
  } else {
    return _calculateFibonacci(number - 1) + _calculateFibonacci(number - 2);
  }
}
