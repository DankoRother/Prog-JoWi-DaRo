import 'package:flutter/material.dart';

// Stateless widget to show a login prompt message.
class LogInPrompt extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Please log in or register to see your content! \n Go to the Account page to log in',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
