import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Sensor MQ-135',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SensorDataScreen(),
    );
  }
}

class SensorDataScreen extends StatefulWidget {
  @override
  _SensorDataScreenState createState() => _SensorDataScreenState();
}

class _SensorDataScreenState extends State<SensorDataScreen> {
  String gasLevel = 'N/A';
  String voltage = 'N/A';
  String timestamp = 'N/A';
  bool isLoading = true;
  bool isRefreshing = false;
  Timer? timer;

  Future<void> fetchData() async {
    try {
      setState(() {
        isRefreshing = true;
      });

      print('Fetching data...');
      final response = await http.get(
          Uri.parse('https://e455-125-164-21-68.ngrok-free.app/api/data'));

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            gasLevel = data[0]['gasLevel'].toString();
            voltage = data[0]['voltage'].toString();
            timestamp = data[0]['timestamp'];
            isLoading = false;
          });
          print(
              'Data updated: Gas Level = $gasLevel, Voltage = $voltage, Timestamp = $timestamp');
        } else {
          setState(() {
            isLoading = false;
            gasLevel = 'No data';
            voltage = 'No data';
            timestamp = 'No data';
          });
          print('No data available from the API.');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        gasLevel = 'Error';
        voltage = 'Error';
        timestamp = 'Error';
      });
      print('Error fetching data: $e');
    } finally {
      setState(() {
        isRefreshing = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) => fetchData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Sensor MQ-135'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if (isRefreshing) ...[
                      Text(
                        'Refreshing data...',
                        style: TextStyle(color: Colors.orange, fontSize: 16),
                      ),
                      SizedBox(height: 10),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildBox('Gas Level', gasLevel),
                        _buildBox('Voltage', voltage),
                      ],
                    ),
                    SizedBox(height: 15),
                    _buildBox('Timestamp', timestamp, isLarge: true),
                  ],
                ),
              ),
      ),
    );
  }

  // Fungsi untuk membuat box
  Widget _buildBox(String title, String value, {bool isLarge = false}) {
    return Container(
      padding: EdgeInsets.all(20),
      width: isLarge ? double.infinity : 150,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
