import 'package:flutter/material.dart';
import 'authentication_provider.dart';
import 'package:provider/provider.dart';
import 'settings.dart';
import 'logInPrompt.dart';
import 'appBar.dart'; // Importiere die custom AppBar

class Friends extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;

    return Scaffold(
      appBar: buildAppBar(
        context: context,
        loggedInTitle: 'Your Friendslist', // Titel wenn eingeloggt
        loggedOutTitle: 'Friends', // Titel wenn nicht eingeloggt
      ),
      body: isLoggedIn ? _buildFriendList() : LogInPrompt(),
    );
  }

  Widget _buildFriendList() {
    return Center(
      child: Text(
        'You don’t have any friends yet.',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
