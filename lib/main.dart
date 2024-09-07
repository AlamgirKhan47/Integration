import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => DataProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DataListScreen(),
      ),
    ),
  );
}

// Data Provider for API Calls and State Management
class DataProvider with ChangeNotifier {
  List<dynamic> _data = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<dynamic> get data => _data;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchData() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
      if (response.statusCode == 200) {
        _data = json.decode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}

// UI for displaying data with loading indicator and error handling
class DataListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data List'),
      ),
      body: Consumer<DataProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (provider.errorMessage.isNotEmpty) {
            return Center(
              child: Text(provider.errorMessage),
            );
          } else {
            return ListView.builder(
              itemCount: provider.data.length,
              itemBuilder: (context, index) {
                final item = provider.data[index];
                return ListTile(
                  title: Text(item['title']),
                  subtitle: Text(item['body']),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<DataProvider>().fetchData();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}
