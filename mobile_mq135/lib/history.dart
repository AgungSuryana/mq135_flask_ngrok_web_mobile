import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart'; // Added import for DateFormat
import 'package:flutter/services.dart'; // Added for hiding status bar

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> historyData = [];
  List<dynamic> filteredData = [];
  bool isLoading = true;
  Timer? dataTimer;
  Timer? clockTimer; // Timer for clock
  String selectedFilter = '15 minutes';
  String currentTime =
      DateFormat('hh:mm:ss a').format(DateTime.now()); // Initial time

  // Function to fetch data from the API
  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('https://072f-125-164-20-239.ngrok-free.app/api/data'),
      );

      if (response.statusCode == 200) {
        // Print the response body to check its structure
        print('Response Body: ${response.body}');

        // Attempt to parse response as a List
        var decodedData = json.decode(response.body);
        if (decodedData is List) {
          setState(() {
            historyData = decodedData;
            filteredData = List.from(historyData);
            isLoading = false;
          });
        } else if (decodedData is Map) {
          // Handle case where the response is a map
          print('Decoded response is a map: $decodedData');
          setState(() {
            historyData = [decodedData]; // If it's a map, wrap it in a list
            filteredData = List.from(historyData);
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      setState(() {
        historyData = [];
        isLoading = false;
      });
    }
  }

  // Function to filter data based on the selected time range
  void filterData() {
    final now = DateTime.now();
    DateTime filterDate;

    switch (selectedFilter) {
      case '1 minute':
        filterDate = now.subtract(Duration(minutes: 1));
        break;
      case '5 minutes':
        filterDate = now.subtract(Duration(minutes: 5));
        break;
      case '15 minutes':
        filterDate = now.subtract(Duration(minutes: 15));
        break;
      case '1 hour':
        filterDate = now.subtract(Duration(hours: 1));
        break;
      case '1 day':
        filterDate = now.subtract(Duration(days: 1));
        break;
      case '3 days':
        filterDate = now.subtract(Duration(days: 3));
        break;
      default:
        filterDate = now.subtract(Duration(minutes: 15)); // Default filter
    }

    print('Filter Date: $filterDate'); // Debugging filter date

    // Filter data based on timestamp
    setState(() {
      filteredData = historyData.where((data) {
        // Parse timestamp using DateTime.parse() for ISO 8601 format
        DateTime timestamp = DateTime.parse(
            data['timestamp']); // This handles ISO format with 'T'

        // Debugging timestamp received
        print('Timestamp: $timestamp');

        // Check if the timestamp is after the filter date
        bool isAfterFilter = timestamp.isAfter(filterDate);
        print(
            'Is timestamp after filter date: $isAfterFilter'); // Debugging filter condition
        return isAfterFilter; // Return true if data matches the filter
      }).toList();

      print('Filtered Data: $filteredData'); // Debugging filtered data
    });
  }

  // Update the filter and apply it to the data
  void updateFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      filterData(); // Apply filter whenever the selected filter changes
    });
  }

  // Function to update the current time in real-time
  void updateClock() {
    setState(() {
      currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    dataTimer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
      fetchData(); // Refresh data every 10 seconds
    });
    clockTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      updateClock(); // Update the clock every second
    });

    // Hide the status bar
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor:
            Colors.transparent, // Transparent to hide the status bar
        statusBarIconBrightness:
            Brightness.light, // Ensure icons are visible if needed
      ),
    );
  }

  @override
  void dispose() {
    dataTimer?.cancel(); // Stop the data refresh timer
    clockTimer?.cancel(); // Stop the clock update timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Move the time display down a bit
          Padding(
            padding: const EdgeInsets.only(
                top: 30.0, bottom: 8.0), // Adjusted padding
            child: Text(
              currentTime,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Row for filter buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilterButton(
                  label: '1 min', // Opsi 1 menit
                  onTap: () => updateFilter('1 minute'),
                ),
                FilterButton(
                  label: '5 min',
                  onTap: () => updateFilter('5 minutes'),
                ),
                FilterButton(
                  label: '15 min',
                  onTap: () => updateFilter('15 minutes'),
                ),
                FilterButton(
                  label: '1 hour',
                  onTap: () => updateFilter('1 hour'),
                ),
                FilterButton(
                  label: '1 day',
                  onTap: () => updateFilter('1 day'),
                ),
                FilterButton(
                  label: '3 days',
                  onTap: () => updateFilter('3 days'),
                ),
              ],
            ),
          ),

          // Display data
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final data = filteredData[index];
                      return Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: ListTile(
                          title: Text(
                            "Timestamp: ${data['timestamp']}", // Access timestamp correctly
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "Gas Level: ${data['gasLevel']}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

// Custom Filter Button widget
class FilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const FilterButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }
}
