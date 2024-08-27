import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'settings.dart';
import 'current_challenges.dart';
import 'main.dart';

class MyAccountState extends StatefulWidget {
  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState
extends State<MyAccountState> {
String userName = 'Danko Rother';
String email = 'john.doe@example.com';
int completedChallenges = 5;              //TODO: Richtige Datenbank hier implementieren

bool isLoggedIn = false;
final TextEditingController _usernameController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: isLoggedIn
        ? AppBar(
      title: Text("My Account"),
      actions: [
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            // Navigate to settings page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          },
        ),
        IconButton(onPressed: (){
          setState(() {
            isLoggedIn = false;
          });
          }, icon: Icon(Icons.logout))
      ],
    )
        : AppBar(), // Empty AppBar when not logged in
    body: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Calculate dynamic values based on screen size
        double screenWidth = constraints.maxWidth;
        double screenHeight = constraints.maxHeight;

        return Center(
          child: isLoggedIn
              ? _buildAccountPage(screenWidth, screenHeight)
              : _buildLoginPage(screenWidth, screenHeight), // Conditionally render login page
        );
      },
    ),
  );
}
Widget _buildAccountPage(double screenWidth, double screenHeight) {
  return Column( // Removed the Scaffold here
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
      SizedBox(height: screenHeight * 0.04),
      CircleAvatar(
        radius: screenHeight * 0.07,
        backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
      ),
      SizedBox(height: screenHeight * 0.022),
      Container(
        padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.012, horizontal: screenWidth * 0.014),
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              textAlign: TextAlign.center,
              maxLines: 1,
              userName,
              style: standardText.copyWith(
                fontSize: standardText.fontSize! * 1.4,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            Text(
              textAlign: TextAlign.center,
              email,
              style: standardText.copyWith(color: Colors.grey),
            ),
            SizedBox(height: screenHeight * 0.025),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all(Colors.blue[900])),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context)
                        => CurrentChallenges()),
                );
              },
              child: Text(
                textAlign: TextAlign.center,
                "Laufende Challenges",
                style: standardText,
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            Text(
              textAlign: TextAlign.center,
              "Abgeschlossene Challenges: $completedChallenges",
              style: standardText.copyWith(
                fontSize: standardText.fontSize! * 1.2,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
Widget _buildLoginPage(double screenWidth, double screenHeight) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _usernameController,
          decoration: InputDecoration(labelText: 'Username'),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(labelText: 'Password'),
        ),
      ),
      ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.blue[900]),
        ),
        onPressed: () {
          if (_usernameController.text == '123' &&
              _passwordController.text == '123') {
            setState(() {
              isLoggedIn = true;
            });
          } else {
            // Show an error message or handle invalid login
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invalid username or password')),
            );
          }
        },
        child: Text(
          'Login',
          style: standardText,
        ),
      ),
    ],
  );
}
}