import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitcheck/login_page.dart';

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User'),
      ),
      body: FutureBuilder(
        future: _getUserDetails(), // Fetch user details from SharedPreferences
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final userDetails = snapshot.data!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                SizedBox(height: 20),
                Text('Name: ${userDetails['name']}'),
                Text('Email: ${userDetails['email']}'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // Clear SharedPreferences and navigate to LoginPage
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage(title: 'Login',)),
                    );
                  },
                  child: Text('Log Out'),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('name');
    String? email = prefs.getString('email');
    return {'name': name, 'email': email};
  }
}
