import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authentication_provider.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final VoidCallback onLogin; // Callback for successful login
  final VoidCallback? onNavigateToRegister; // Callback for navigating to register

  const LoginPage({
    Key? key,
    required this.usernameController,
    required this.passwordController,
    required this.onLogin,
    this.onNavigateToRegister,
  }) : super(key: key);

  Future<void> attemptLogin(BuildContext context) async {
    if (usernameController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.login(
          usernameController.text,
          passwordController.text,
          context,
        );

        if (authProvider.isLoggedIn) {
          onLogin(); // Use the onLogin callback passed from the parent
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error during login: $e'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: SingleChildScrollView( // To prevent overflow on smaller screens
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: screenHeight * 0.1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                onSubmitted: (_) => attemptLogin(context),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue[900]),
              ),
              onPressed: () {
                attemptLogin(context);
              },
              child: Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenHeight * 0.02,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.pink[700]),
              ),
              onPressed: onNavigateToRegister != null
                  ? onNavigateToRegister
                  : null,
              child: Text(
                'Register',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenHeight * 0.02,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
