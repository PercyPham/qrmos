import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/qrmos.dart' as qrmos_api;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;
  String _apiServerHealth = "loading...";

  @override
  void initState() {
    super.initState();
    () async {
      var apiResp = await qrmos_api.checkHealth();
      if (apiResp.error != null) {
        setState(() {
          _apiServerHealth = apiResp.error!.message;
        });
        return;
      }
      setState(() {
        _apiServerHealth = apiResp.data ?? "";
      });
    }();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    var _selectedValue = 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              _selectedValue = value as int;
              // ignore: avoid_print
              print(_selectedValue);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                child: Text("item1"),
                value: 1,
              ),
              const PopupMenuItem(
                child: Text("item2"),
                value: 2,
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            AppBar(
              title: const Text("hello"),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.shop,
              ),
              title: const Text("shop"),
              onTap: () {
                // ignore: avoid_print
                print("shop pressed");
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('API server\'s health: ' + _apiServerHealth),
            const Text(""),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
