import 'package:flutter/material.dart';

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
      title: const Text("My Account"),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            // Navigate to settings page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => _buildEditAccountPage(screenWidth, screenHeight)),
            );
          },
        ),
        IconButton(onPressed: (){
          setState(() {
            isLoggedIn = false;
          });
          }, icon: const Icon(Icons.logout))
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
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
      SizedBox(height: screenHeight * 0.04),
      CircleAvatar(
        radius: screenHeight * 0.07,
        backgroundImage: const AssetImage('assets/images/profile_placeholder.png'),
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
                  WidgetStateProperty.all(Colors.blue[900])),
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
            SizedBox(height: screenHeight * 0.015),
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
          decoration: const InputDecoration(labelText: 'Username'),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
      ),
      ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.blue[900]),
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
              const SnackBar(content: Text('Invalid username or password')),
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
Widget _buildEditAccountPage(double screenWidth, double screenHeight) {
  // Create TextEditingControllers to manage the input fields
  final TextEditingController _userNameController = TextEditingController(
      text: userName);
  final TextEditingController _emailController = TextEditingController(
      text: email);

  return Scaffold( // Wrap the entire content with Scaffold
    body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: screenHeight * 0.04),
        CircleAvatar(
          radius: screenHeight * 0.07,
          backgroundImage: const AssetImage(
              'assets/images/profile_placeholder.png'),
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
              // Editable username field
              TextField(
                controller: _userNameController,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: standardText.copyWith(
                  fontSize: standardText.fontSize! * 1.4,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter new username',
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              // Editable email field
              TextField(
                controller: _emailController,
                textAlign: TextAlign.center,
                style: standardText.copyWith(color: Colors.grey),
                decoration: const InputDecoration(
                  hintText: 'Enter new email',
                ),
              ),
              SizedBox(height: screenHeight * 0.025),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                    WidgetStateProperty.all(Colors.blue[900])),
                onPressed: () {
                  // TODO: Datenbanklogik!! Erst danach darf myAccountState neu geladen werden
                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context)
                      => _buildAccountPage(screenWidth, screenHeight)),
                    );
                  });
                },
                child: Text(
                  textAlign: TextAlign.center,
                  "Submit Changes",
                  style: standardText,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              // Display completed challenges (non-editable)
              Text(
                textAlign: TextAlign.center,
                "Abgeschlossene Challenges: $completedChallenges",
                style: standardText.copyWith(
                  fontSize: standardText.fontSize! * 1.2,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
            ],
          ),
        ),
      ],
    ),
  );
}
}