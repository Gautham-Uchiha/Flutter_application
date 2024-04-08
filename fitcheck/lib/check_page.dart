import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckPage extends StatefulWidget {
  const CheckPage({Key? key, required String title}) : super(key: key);

  @override
  _CheckPageState createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _heightController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _bpController = TextEditingController();

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
        title: Text('FitCheck'),
        actions: [
          IconButton(
            onPressed: () {
              // Handle Past Records button press
              _showPastRecordsDialog();
            },
            icon: Icon(Icons.history),
          ),
          IconButton(
            onPressed: () {
              // Handle User button press
            },
            icon: Icon(Icons.person),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(labelText: 'Height (cm)'),
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
                decoration: InputDecoration(labelText: 'Weight (kg)'),
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
                decoration: InputDecoration(labelText: 'Blood Pressure'),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your blood pressure';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Perform health check based on input values
                    double height = double.parse(_heightController.text);
                    double weight = double.parse(_weightController.text);
                    String bp = _bpController.text;

                    // Record date and time of the health check
                    DateTime now = DateTime.now();
                    String timestamp = now.toString();

                    // You can implement health check logic here
                    // For demonstration, let's assume a simple check
                    if (weight / ((height / 100) * (height / 100)) >= 18.5 &&
                        weight / ((height / 100) * (height / 100)) <= 24.9) {
                      _healthStatus = 'You are within the normal weight range.';
                    } else {
                      _healthStatus = 'You are not within the normal weight range.';
                    }

                    // Save the health check record
                    _saveRecord(timestamp, _healthStatus);

                    // Show the result to the user
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Health Check Result'),
                        content: Text(_healthStatus),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Text('Check Health'),
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
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
