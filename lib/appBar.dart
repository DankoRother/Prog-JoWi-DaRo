import 'package:flutter/material.dart';
import 'authentication_provider.dart';
import 'package:provider/provider.dart';
import 'settings.dart';

// Reusable AppBar widget that accepts titles based on login state
PreferredSizeWidget buildAppBar({
  required BuildContext context,
  required String loggedInTitle,
  required String loggedOutTitle,
}) {
  final authProvider = Provider.of<AuthProvider>(context);
  final isLoggedIn = authProvider.isLoggedIn;

  return AppBar(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          alignment: Alignment.center,
          child: Text(
            isLoggedIn ? loggedInTitle : loggedOutTitle,
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
                MaterialPageRoute(builder: (context) => const SettingsPage()),
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
  );
}
