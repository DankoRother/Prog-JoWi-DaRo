import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'settings.dart';
import 'current_challenges.dart';
import 'create_challenges.dart';
import 'welcome_screen.dart';
import 'my_account.dart';
import 'challenge_created_confirmation.dart';

class AddFriendToChallenge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 8),
            Container(
              alignment: Alignment.center,
              child: Text(
                'Add your Friends',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey.shade400, Colors.pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Center(
        child: Text('Here you can add the friends you´d like to challenge.'),
      ),
    );
  }
}