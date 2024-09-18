import 'package:flutter/material.dart';
import 'main.dart'; // Import for standardText

// Assuming you have a way to navigate to CurrentChallenges in your main app structure
// You might need to use a Navigator or a callback here
import 'current_challenges.dart';

class AccountPage extends StatelessWidget {
  final String userName;
  final String email;
  final String shortDescription;
  final int completedChallenges;
  final List<int> interests;
  final Map<int, String> allInterests;

  const AccountPage({
    Key? key,
    required this.userName,
    required this.email,
    required this.shortDescription,
    required this.completedChallenges,
    required this.interests,
    required this.allInterests,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: screenHeight * 0.04),
        CircleAvatar(
          radius: screenHeight * 0.07,
          backgroundImage: const AssetImage('assets/images/profile_placeholder.png'),
        ),
        SizedBox(height: screenHeight * 0.022),
        Container(
          padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.012, horizontal: screenWidth * 0.07),
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                textAlign: TextAlign.center,
                maxLines: 1,
                userName,
                style: standardText.copyWith(
                  fontSize: standardText.fontSize! * 1.4,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.005),
              Text(
                textAlign: TextAlign.center,
                shortDescription,
                style: standardText.copyWith(color: Colors.grey[300]),
              ),
              SizedBox(height: screenHeight * 0.010),
              Text(
                textAlign: TextAlign.center,
                email,
                style: standardText.copyWith(color: Colors.grey),
              ),
              SizedBox(height: screenHeight * 0.025),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.blue[900])),
                onPressed: () {
                  // Navigate to CurrentChallenges
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CurrentChallenges()),
                  );
                },
                child: Text(
                  textAlign: TextAlign.center,
                  "Laufende Challenges",
                  style: standardText,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              Text(
                textAlign: TextAlign.center,
                "Abgeschlossene Challenges: $completedChallenges",
                style: standardText.copyWith(
                  fontSize: standardText.fontSize! * 1.2,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: interests.map((interestId) {
                  return Chip(
                    label: Text(allInterests[interestId]!),
                    backgroundColor: Colors.blueGrey[300],
                  );
                }).toList(),
              ),
              SizedBox(height: screenHeight * 0.005),
            ],
          ),
        ),
      ],
    );
  }
}