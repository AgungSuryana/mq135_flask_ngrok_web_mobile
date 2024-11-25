import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Battery Visualization',
      debugShowCheckedModeBanner: false, // Menghilangkan logo debug
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const SensorDataScreen(),
    );
  }
}

class SensorDataScreen extends StatefulWidget {
  const SensorDataScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SensorDataScreenState createState() => _SensorDataScreenState();
}

class _SensorDataScreenState extends State<SensorDataScreen> {
  double gasLevel = 0.0;
  List<dynamic> sensorData = [];
  bool isLoading = true;
  Timer? timer;

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('https://f580-125-164-25-162.ngrok-free.app/api/data'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          gasLevel = data.isNotEmpty
              ? double.parse(data[0]['gasLevel'].toString())
              : 0.0;
          sensorData = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      setState(() {
        gasLevel = 0.0;
        sensorData = [];
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    timer = Timer.periodic(const Duration(seconds: 10), (Timer t) => fetchData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background warna hitam
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Baterai Visualization
                    Text(
                      'Gas Level: ${gasLevel.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildBatteryIndicator(),
                    const SizedBox(height: 30),

                    // Tabel Scrollable
                    Expanded(
                      child: _buildScrollableTable(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildBatteryIndicator() {
    double batteryHeight = 200.0;
    double batteryWidth = 100.0;
    double levelHeight = (gasLevel / 300) * batteryHeight;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: batteryHeight,
          width: batteryWidth,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green, width: 3),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          height: levelHeight,
          width: batteryWidth - 6,
          decoration: BoxDecoration(
            color: gasLevel > 100
                ? Colors.red
                : gasLevel > 60
                    ? Colors.yellow
                    : Colors.green,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(7)),
          ),
        ),
        Positioned(
          top: -10,
          child: Container(
            height: 10,
            width: batteryWidth / 2,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScrollableTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical, 
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, 
        child: DataTable(
          columnSpacing: 20,
          // ignore: deprecated_member_use
          headingRowColor: MaterialStateProperty.all(Colors.green[700]),
          columns: const [
            DataColumn(
              label: Text(
                'Timestamp',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text(
                'Gas Level',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
          rows: sensorData.map((data) {
            return DataRow(cells: [
              DataCell(Text(data['timestamp'],
                  style: const TextStyle(color: Colors.white))),
              DataCell(Text(data['gasLevel'].toString(),
                  style: const TextStyle(color: Colors.white))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
