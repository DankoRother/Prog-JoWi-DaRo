import 'package:flutter/material.dart';

import 'settings.dart';
import 'main.dart';

class YourChallenges extends StatefulWidget {
  const YourChallenges({super.key});

  @override
  _YourChallengesState createState() => _YourChallengesState();
}

class _YourChallengesState extends State<YourChallenges> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // The container with the page content
          Align(
            alignment: Alignment.topCenter,  // Horizontal centering, arranged at the top
            child: Container(
              width: screenWidth * 0.75,  // Fixed width
              margin: EdgeInsets.only(top: screenHeight * 0.04),  // Spacing from the top
              padding: EdgeInsets.all(screenWidth * 0.02),  // Inner spacing
              decoration: BoxDecoration(
                color: Colors.indigoAccent,  // Background color of the container
                borderRadius: BorderRadius.circular(screenWidth * 0.4*0.08),  // Rounding the corners
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,  // Minimizes the size of the column
                children: [
                  Text(
                    'Your Challenges',
                    style: standardText.copyWith(fontWeight: FontWeight.bold, fontSize: screenHeight*0.03),  // Text style heading
                    textAlign: TextAlign.center,  // Text centering
                  ),
                  SizedBox(height: screenHeight * 0.02),  // Spacing between text and first text field
                  TextField(
                    decoration: InputDecoration(
                      hintStyle: standardText.copyWith(fontSize: screenWidth*0.04, color: Colors.black),
                      hintText: 'Height: $screenHeight width: $screenWidth', // Display the dimensions for development TODO: Remove before final product
                      border: const OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(vertical: screenWidth*0.01, horizontal: screenWidth*0.02),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),  // Spacing between the text fields
                  TextField(
                    decoration: InputDecoration(
                      hintStyle: standardText.copyWith(fontSize: screenWidth*0.04, color: Colors.black),
                      hintText: 'Challenge 2',
                      border: const OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(vertical: screenWidth*0.01, horizontal: screenWidth*0.02),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),  // Spacing between the text fields
                  TextField(
                    decoration: InputDecoration(
                      hintStyle: standardText.copyWith(fontSize: screenWidth*0.04, color: Colors.black),
                      hintText: 'Challenge 3',
                      border: const OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(vertical: screenWidth*0.01, horizontal: screenWidth*0.02),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),  // Spacing between the last text field and the button
                  ElevatedButton.icon(onPressed: () {
                    print('Button pressed'); // Translated from 'Button gedrückt'
                  },
                    icon: const Icon(Icons.favorite_border),
                    label: Text('Like',style: standardText.copyWith(fontWeight: FontWeight.bold, fontSize: screenHeight * 0.03)),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blueGrey,   // Button text color
                      padding: EdgeInsets.only(right: screenWidth * 0.025, left: screenWidth*0.025, top: screenHeight * 0.005, bottom: screenHeight * 0.005), // Button inner spacing
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Rounding the corners
                      ),
                    ),

                  )
                ],
              ),
            ),
          ),

          // Settings icon top left
          Positioned(
            top: screenWidth * 0.008,  // Spacing from the top (including status bar)
            left: screenWidth * 0.008,  // Spacing from the left
            child: IconButton(
              icon: const Icon(Icons.settings),
              color: Colors.white,  // Color of the icon
              iconSize: screenWidthAndHeight*0.025,  // Size of the icon
              onPressed: () {
                // Here comes the navigation to the settings page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}