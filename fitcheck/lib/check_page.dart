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
  final TextEditingController _temperatureController = TextEditingController(); // Added temperature controller

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
                decoration: InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _bpController,
                decoration: InputDecoration(
                  labelText: 'Blood Pressure',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your blood pressure';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _heartRateController,
                decoration: InputDecoration(
                  labelText: 'Heart Rate (bpm)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your heart rate';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _temperatureController,
                decoration: InputDecoration(
                  labelText: 'Temperature (°C)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your temperature';
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
                    double temperature = double.parse(_temperatureController.text); // Parse temperature value

                    // Validate input values
                    if (height <= 0 || weight <= 0 || heartRate <= 0 || temperature <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Height, weight, heart rate, and temperature must be greater than zero')),
                      );
                      return;
                    }

                    // Perform health check logic
                    String healthStatus = '';

                    // Check BMI (Body Mass Index)
                    double bmi = weight / ((height / 100) * (height / 100));
                    if (bmi >= 18.5 && bmi <= 24.9) {
                      healthStatus += 'Your BMI is within the normal range.\n';
                    } else {
                      healthStatus += 'Your BMI is not within the normal range.\n';
                    }

                    // Check Blood Pressure
                    List<String> bpValues = bp.split('/'); // Assuming format is systolic/diastolic
                    int systolic = int.parse(bpValues[0]);
                    int diastolic = int.parse(bpValues[1]);
                    if (systolic < 120 && diastolic < 80) {
                      healthStatus += 'Your blood pressure is normal.\n';
                    } else {
                      healthStatus += 'Your blood pressure is high.\n';
                    }

                    // Check Heart Rate
                    if (heartRate >= 60 && heartRate <= 100) {
                      healthStatus += 'Your heart rate is normal.\n';
                    } else {
                      healthStatus += 'Your heart rate is abnormal.\n';
                    }

                    // Check Temperature
                    if (temperature >= 36.1 && temperature <= 37.2) {
                      healthStatus += 'Your body temperature is normal.';
                    } else {
                      healthStatus += 'Your body temperature is abnormal.';
                    }

                    // Record date and time of the health check
                    DateTime now = DateTime.now();
                    String timestamp = now.toString();

                    // Save the health check record
                    _saveRecord(timestamp, healthStatus);

                    // Show the result to the user
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Health Check Result'),
                        content: Text(healthStatus),
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
