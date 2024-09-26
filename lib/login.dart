import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authentication_provider.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;
  final VoidCallback? onNavigateToRegister;

  const LoginPage({
    Key? key,
    required this.usernameController,
    required this.passwordController,
    required this.onLogin,
    this.onNavigateToRegister,
  }) : super(key: key);

  Future<void> _attemptLogin(BuildContext context) async {
    if (usernameController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.login(
          usernameController.text,
          passwordController.text,
          context,
        );

        if (authProvider.isLoggedIn) {
          onLogin();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during login: $e'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: SingleChildScrollView(
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
                onSubmitted: (_) => _attemptLogin(context),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue[900]),
              ),
              onPressed: () => _attemptLogin(context),
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
              onPressed: onNavigateToRegister,
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
