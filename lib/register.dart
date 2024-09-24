import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'accountController.dart';
import 'main.dart'; // Import for standardText

class RegisterPage extends StatelessWidget {
  final Function(String, String) onRegister;
  RegisterPage({Key? key, required this.onRegister}) : super(key: key);

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void proceedToDetails(BuildContext context) async {
    if (_usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: _usernameController.text)
            .get();

        if (querySnapshot.docs.isEmpty) {
          onRegister(_usernameController.text, _passwordController.text);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.pink[700],
              content: Text('Username already taken.'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error during registration: $e'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.pink[700],
          content: Text('Please fill in all fields.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
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
                onSubmitted: (_) => proceedToDetails(context),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.blue[900]),
              ),
              onPressed: () {
                proceedToDetails(context);
              },
              child: Text(
                'Next', // Changed from 'Register' to 'Next'
                style: standardText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}