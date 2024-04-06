import 'package:flutter/material.dart';
import 'package:myapp2/fourth.dart';

class Third extends StatefulWidget {
  const Third({Key? key, required this.title});
  final String title;

  @override
  _ThirdState createState() => _ThirdState();
}

class _ThirdState extends State<Third> {
  String _name = '';

  void _changename(String val) {
    setState(() {
      _name = val;
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Name: $_name",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(150.0),
              child: TextField(
                onChanged: (value) {
                  _changename(value);
                },
                decoration: const InputDecoration(
                  label: Text("Enter Name"),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  if (_name.isNotEmpty && _name!="Enter a name") {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Fourth(title: _name)));
                  } else {
                    _changename("Enter a name");
                  }
                },
                child: const Text("Enter"))
          ],
        ),
      ),
    );
  }
}
