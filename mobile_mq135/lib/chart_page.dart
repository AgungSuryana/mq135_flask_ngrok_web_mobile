import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  List<FlSpot> dataPoints = [];
  bool isLoading = true;
  Timer? timer;

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('https://072f-125-164-20-239.ngrok-free.app/api/data'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          dataPoints = data
              .asMap()
              .entries
              .map((entry) => FlSpot(entry.key.toDouble(),
                  double.parse(entry.value['gasLevel'].toString())))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      setState(() {
        dataPoints = [];
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    timer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
      fetchData();
    });
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
        title: const Text('Gas Level Chart'),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: LineChart(
                LineChartData(
                  backgroundColor: Colors.black,
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value
                                .toInt()
                                .toString(), // Menampilkan angka tanpa .0
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value
                                .toInt()
                                .toString(), // Menampilkan angka tanpa .0
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.white),
                  ),
                  minY: 0,
                  maxY: 300,
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: false),
                      spots: dataPoints,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
