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

class _MyAccountState extends State<MyAccountState> {
  //Test data TODO: Nutzerdatenbankanbindung
  String userName = "Testnutzer (Später über DB zu lösen)";
  String email = "email.com";
  int completedChallenges = 19387425;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Account"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // Calculate dynamic values based on screen size
            double screenWidth = constraints.maxWidth;
            double screenHeight = constraints.maxHeight;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: screenHeight * 0.07,
                    // Dynamic radius based on screen height
                    backgroundImage: AssetImage(
                        'assets/images/profile_placeholder.png'),
                  ),
                  SizedBox(height: screenHeight * 0.025), // Dynamic spacing
                  Text(
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    userName,
                    style: standardText.copyWith(
                      fontSize: standardText.fontSize! * 1.4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015), // Dynamic spacing
                  Text(
                    textAlign: TextAlign.center,
                    email,
                    style: standardText.copyWith(color: Colors.grey),
                  ),
                  SizedBox(height: screenHeight * 0.025), // Dynamic spacing
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CurrentChallenges()),
                      );
                    },
                    child: Text(
                      textAlign: TextAlign.center,
                      "Laufende Challenges",
                      style: standardText,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015), // Dynamic spacing
                  Text(
                    textAlign: TextAlign.center,
                    "Abgeschlossene Challenges: $completedChallenges",
                    style: standardText.copyWith(
                      fontSize: standardText.fontSize! * 1.2,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
    );
  }
}