import 'package:flutter/material.dart';
import 'authentication_provider.dart'; // Import the authentication provider
import 'package:provider/provider.dart'; // Import the provider package for state management
import 'settings.dart'; // Import settings page
import 'logInPrompt.dart'; // Import login prompt widget
import 'appBar.dart';

class Friends extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context); // Access the authentication provider
    final isLoggedIn = authProvider.isLoggedIn; // Check if the user is logged in

    return Scaffold(
      appBar: buildAppBar(
        context: context,
        loggedInTitle: 'Your Friendslist', // Title when logged in
        loggedOutTitle: 'Friends', // Title when logged out
      ),
      body: isLoggedIn ? _buildFriendList() : LogInPrompt(), // Display friend list or login prompt based on authentication status
    );
  }

  // Widget to build the friend list view
  Widget _buildFriendList() {
    return Center(
      child: Text(
        'You don’t have any friends yet.', // Message indicating no friends found
        style: TextStyle(
          color: Colors.white, // Set text color to white
        ),
      ),
    );
  }
}