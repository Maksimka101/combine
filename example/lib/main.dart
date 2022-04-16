import 'package:combine/combine.dart';
import 'package:flutter/material.dart';

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
  ICombineIsolate? _combineIsolate;

  @override
  void initState() {
    super.initState();

    Combine().spawn((context) {
      final messenger = context.isolateMessenger;
      var counter = 0;
      messenger.messagesStream.listen((event) {
        if (event == "increment") {
          messenger.send(++counter);
        }
      });
    }).then((isolate) {
      _combineIsolate = isolate;
      setState(() {});
      isolate.isolateMessenger.messagesStream.listen((event) {
        if (event is int) {
          _counter = event;
          setState(() {});
        }
      });
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
          if (_combineIsolate == null)
            const Text("Isolate is creating")
          else
            ListTile(
              title: Text("Counter: $_counter"),
              trailing: IconButton(
                onPressed: _onIncrementCounter,
                icon: const Icon(Icons.add),
              ),
            )
        ],
      ),
    );
  }

  void _onIncrementCounter() {
    _combineIsolate?.isolateMessenger.send("increment");
  }
}
