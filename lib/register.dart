import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

/// A stateless widget that represents the registration page of the application.
class RegisterPage extends StatelessWidget {
  /// Callback function to execute when registration proceeds to details.
  final Function(String, String) onRegister;

  /// Creates a [RegisterPage] with the required callback.
  RegisterPage({Key? key, required this.onRegister}) : super(key: key);

  /// Controller for the username input field.
  final TextEditingController _usernameController = TextEditingController();

  /// Controller for the password input field.
  final TextEditingController _passwordController = TextEditingController();

  /// Attempts to proceed to the registration details page.
  ///
  /// Validates the username's uniqueness before proceeding.
  Future<void> _proceedToDetails(BuildContext context) async {
    if (_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      try {
        // Query Firestore to check if the username is already taken.
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: _usernameController.text)
            .get();

        if (querySnapshot.docs.isEmpty) {
          // If username is unique, proceed to the next registration step.
          onRegister(_usernameController.text, _passwordController.text);
        } else {
          // Inform the user that the username is already taken.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.pink[700],
              content: const Text('Username already taken.'),
            ),
          );
        }
      } catch (e) {
        // Show an error message if an exception occurs during registration.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.pink[700],
            content: Text('Error during registration: $e'),
          ),
        );
      }
    } else {
      // Prompt the user to fill in all fields if any are empty.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.pink[700],
          content: const Text('Please fill in all fields.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtain screen dimensions for responsive design.
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: screenHeight * 0.15),
              // Display the registration icon.
              Icon(
                Icons.app_registration,
                size: screenHeight * 0.15,
                color: Colors.pink[600],
              ),
              SizedBox(height: screenHeight * 0.05),
              // Username input field.
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person, color: Colors.pink[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: standardText.copyWith(
                  color: Colors.white,
                  fontSize: screenHeight * 0.025,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              // Password input field with obscured text.
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: Colors.pink[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: standardText.copyWith(
                  color: Colors.white,
                  fontSize: screenHeight * 0.025,
                ),
                // Attempt to proceed when the user submits the password field.
                onSubmitted: (_) => _proceedToDetails(context),
              ),
              SizedBox(height: screenHeight * 0.04),
              // Next button with icon to proceed to registration details.
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => _proceedToDetails(context),
                icon: Icon(Icons.arrow_forward, color: Colors.white),
                label: Text(
                  'Next',
                  style: standardText.copyWith(
                    color: Colors.white,
                    fontSize: screenHeight * 0.025,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.1),
            ],
          ),
        ),
      ),
    );
  }
}
