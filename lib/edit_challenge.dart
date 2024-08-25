import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';



class EditChallenge extends StatefulWidget {
  @override
  _EditChallengeState createState() => _EditChallengeState();
}

class _EditChallengeState extends State<EditChallenge> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Verhindert, dass der Standard-Zurückpfeil erscheint
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.clear),
              color: Colors.white,
              iconSize: 30,
              onPressed: () {
                print('Close EditFile');
                Navigator.pop(context);
              },
            ),
            SizedBox(width: 8),
            Text(
              'Edit Challenge',
              style: TextStyle(
                color: Colors.white,
                //fontWeight: FontWeight.bold,
                fontSize: 25,
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
        child: Text('Here you can edit your daily quest about your challenge.'),
      ),
    );
  }
}