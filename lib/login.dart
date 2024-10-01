import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authentication_provider.dart';
import 'main.dart';

/// A stateless widget that represents the login page of the application.
class LoginPage extends StatelessWidget {
  /// Controller for the username input field.
  final TextEditingController usernameController;

  /// Controller for the password input field.
  final TextEditingController passwordController;

  /// Callback function to execute upon successful login.
  final VoidCallback onLogin;

  /// Optional callback to navigate to the registration page.
  final VoidCallback? onNavigateToRegister;

  /// Creates a [LoginPage] with the required controllers and callbacks.
  const LoginPage({
    Key? key,
    required this.usernameController,
    required this.passwordController,
    required this.onLogin,
    this.onNavigateToRegister,
  }) : super(key: key);

  /// Attempts to log in the user with the provided credentials.
  ///
  /// Displays appropriate messages based on the outcome.
  Future<void> _attemptLogin(BuildContext context) async {
    if (usernameController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      try {
        // Access the authentication provider without listening for changes.
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        // Attempt to log in with the provided username and password.
        await authProvider.login(
          usernameController.text,
          passwordController.text,
          context,
        );

        // If login is successful, execute the onLogin callback.
        if (authProvider.isLoggedIn) {
          onLogin();
        }
      } catch (e) {
        // Show an error message if an exception occurs during login.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.pink[700],
            content: Text('Error during login: $e'),
          ),
        );
      }
    } else {
      // Prompt the user to fill in all fields if any are empty.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.pink,
          content: Text('Please fill in all fields.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtain screen dimensions for responsive design.
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: screenHeight * 0.15),
            // Display the account circle icon.
            Icon(
              Icons.account_circle,
              size: screenHeight * 0.15,
              color: Colors.pink[600],
            ),
            SizedBox(height: screenHeight * 0.05),
            // Username input field.
            TextField(
              controller: usernameController,
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
              controller: passwordController,
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
              // Attempt login when the user submits the password field.
              onSubmitted: (_) => _attemptLogin(context),
            ),
            SizedBox(height: screenHeight * 0.04),
            // Login button with icon.
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
              onPressed: () => _attemptLogin(context),
              icon: Icon(Icons.login, color: Colors.white),
              label: Text(
                'Login',
                style: standardText.copyWith(
                  color: Colors.white,
                  fontSize: screenHeight * 0.025,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            // Register button with icon.
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[700],
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                  horizontal: screenWidth * 0.15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: onNavigateToRegister,
              icon: Icon(Icons.app_registration, color: Colors.white),
              label: Text(
                'Register',
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
    );
  }
}
