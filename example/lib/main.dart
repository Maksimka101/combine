import 'package:combine/combine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _counter = 0;
  var _loadedAssetString = "No assets loaded";
  ICombineIsolate? _counterIsolate;
  ICombineIsolate? _assetsIsolate;

  @override
  void initState() {
    super.initState();
    _createCounterIsolate();
    _createAssetsIsolate();
  }

  Future<void> _createCounterIsolate() async {
    final isolate = await Combine().spawn(
      (context) {
        final messenger = context.isolateMessenger;
        var counter = 0;
        messenger.messagesStream.listen((event) {
          if (event == "increment") {
            messenger.send(++counter);
          }
        });
      },
      debugName: "counter",
    );

    _counterIsolate = isolate;
    setState(() {});
    isolate.messenger.messagesStream.listen((event) {
      if (event is int) {
        _counter = event;
        setState(() {});
      }
    });
  }

  Future<void> _createAssetsIsolate() async {
    final isolate = await Combine().spawn<String>(
      (context) {
        final messenger = context.isolateMessenger;

        messenger.messagesStream.listen((event) async {
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
      argument: "initial asset",
      argumentsMap: {"initial": "asset"},
    );

    _assetsIsolate = isolate;
    setState(() {});
    isolate.messenger.messagesStream.listen((event) {
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
              title: const Text("Loaded asset:"),
              subtitle: Text(_loadedAssetString),
              onTap: _onLoadAsset,
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
  }
}