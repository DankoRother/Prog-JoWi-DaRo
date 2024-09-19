import 'package:flutter/material.dart';
import 'authentication_provider.dart';
import 'package:provider/provider.dart';
import 'settings.dart';
import 'logInPrompt.dart';


class Friends extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context); // AuthProvider abrufen
    final isLoggedIn = authProvider.isLoggedIn; // Anmeldestatus abrufen

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.center,
              child: Text(
                isLoggedIn ? 'Your Friendslist' : 'Friends',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            if (isLoggedIn)
              IconButton(
                icon: const Icon(Icons.settings),
                color: Colors.white,
                iconSize: 30,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()),
                  );
                },
              ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink, Colors.blueGrey.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoggedIn ? _buildFriendList() : LogInPrompt(),
    );
  }

  Widget _buildFriendList() {
    return Center(
      child: Text(
        'You don´t have any friends yet.',
          style: TextStyle(
            color: Colors.white,
        ),
      ),
    );
  }
}