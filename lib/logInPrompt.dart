import 'package:flutter/material.dart';

// Stateless widget to show a login prompt message.
class LogInPrompt extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return const Center(
      // Center widget to align the content in the middle of the screen
      child: Padding(
        padding: EdgeInsets.all(16.0), // Adds padding around the content
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centers the column vertically
          children: <Widget>[
            // Display a message prompting the user to log in or register
            Text(
              'Please log in or register to see your content! \n Go to the Account page to log in',
              style: TextStyle(
                fontSize: 20, // Set text size
                color: Colors.black54, // Set text color
                fontStyle: FontStyle.italic, // Italicize the text
              ),
              textAlign: TextAlign.center, // Align the text to the center
            ),
          ],
        ),
      ),
    );
  }
}
