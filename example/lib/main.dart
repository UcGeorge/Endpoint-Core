import 'package:flutter/material.dart';
import 'package:endpoint_core/endpoint_core.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Endpoint Core Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Endpoint Core Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _apiResult = 'No API call made yet';

  Future<void> _callCountryApi() async {
    try {
      final countryApi = CountryStateCityApi.endpoints();
      final countries =
          await countryApi["getAllCountries"]!.call<List<dynamic>>(
        map: (data) => data as List<dynamic>,
      );
      setState(() {
        _apiResult = 'Countries: ${countries?.take(5)}...';
      });
    } catch (e) {
      setState(() {
        _apiResult = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _callUserApi() async {
    try {
      final userApi = UserManagementApi.endpoints();
      final loginResult = await userApi["login"]!.call<Map<String, dynamic>>(
        data: {"username": "example@email.com", "password": "password123"},
        map: (data) => data as Map<String, dynamic>,
      );
      setState(() {
        _apiResult = 'Login result: $loginResult';
      });
    } catch (e) {
      setState(() {
        _apiResult = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _callCountryApi,
              child: const Text('Call Country API'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _callUserApi,
              child: const Text('Call User API'),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _apiResult,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
