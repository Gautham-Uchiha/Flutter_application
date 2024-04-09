import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitcheck/user_page.dart'; // Import user_page.dart

class CheckPage extends StatefulWidget {
  const CheckPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _CheckPageState createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bpController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController(); // Added heart rate controller

  String _healthStatus = '';
  List<String> _pastRecords = [];

  @override
  void initState() {
    super.initState();
    _loadPastRecords();
  }

  void _loadPastRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _pastRecords = prefs.getStringList('past_records') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitCheck'),
        actions: [
          IconButton(
            onPressed: () {
              _showPastRecordsDialog();
            },
            icon: const Icon(Icons.history),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserPage())); // Navigate to UserPage when user button is clicked
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _bpController,
                decoration: const InputDecoration(labelText: 'Blood Pressure'),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your blood pressure';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _heartRateController,
                decoration: const InputDecoration(labelText: 'Heart Rate (bpm)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your heart rate';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    double height = double.parse(_heightController.text);
                    double weight = double.parse(_weightController.text);
                    String bp = _bpController.text;
                    int heartRate = int.parse(_heartRateController.text); // Parse heart rate value

                    // Validate input values
                    if (height <= 0 || weight <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Height and weight must be greater than zero')),
                      );
                      return;
                    }

                    // Perform health check logic
                    // For demonstration, let's assume a simple check
                    if (weight / ((height / 100) * (height / 100)) >= 18.5 &&
                        weight / ((height / 100) * (height / 100)) <= 24.9) {
                      _healthStatus = 'You are within the normal weight range.';
                    } else {
                      _healthStatus = 'You are not within the normal weight range.';
                    }

                    // Record date and time of the health check
                    DateTime now = DateTime.now();
                    String timestamp = now.toString();

                    // Save the health check record
                    _saveRecord(timestamp, _healthStatus);

                    // Show the result to the user
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Health Check Result'),
                        content: Text(_healthStatus),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: const Text('Check Health'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveRecord(String timestamp, String result) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> records = prefs.getStringList('past_records') ?? [];
    records.add('$timestamp: $result');
    await prefs.setStringList('past_records', records);
    _loadPastRecords();
  }

  void _showPastRecordsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Past Records'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _pastRecords.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_pastRecords[index]),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
