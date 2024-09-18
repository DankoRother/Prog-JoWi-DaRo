import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authentication_provider.dart';
import 'main.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final VoidCallback onLogin; // Callback for successful login
  final VoidCallback? onNavigateToRegister; // Add this line
  const LoginPage({
    Key? key,
    required this.usernameController,
    required this.passwordController,
    required this.onLogin,
    this.onNavigateToRegister, // Add this line
  }) : super(key: key);

  void attemptLogin(BuildContext context) async {
    if (usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.login(
          usernameController.text,
          passwordController.text,
          context
        );

        if (authProvider.isLoggedIn) {
          onLogin(); // Call the callback on successful login
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error during login: $e'),
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
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
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.blue[900]),
            ),
            onPressed: () {
              attemptLogin(context);
            },
            child: Text(
              'Login',
              style: standardText,
            ),
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
              WidgetStateProperty.all(Colors.green[700]),
            ),
            onPressed: onNavigateToRegister != null
                ? () => onNavigateToRegister!()  // Wrap the callback in a function
                : null,
            child: Text(
              'Register',
              style: standardText,
            ),
          ),
        ],
      ),
    );
  }
}