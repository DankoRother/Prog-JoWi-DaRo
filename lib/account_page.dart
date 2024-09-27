import 'package:flutter/material.dart';
import 'main.dart';
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
            vertical: screenHeight * 0.012,
            horizontal: screenWidth * 0.07,
          ),
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                userName,
                textAlign: TextAlign.center,
                style: standardText.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: screenHeight*0.04,
                  color: Colors.pink[600]
                )
              ),
              SizedBox(height: screenHeight * 0.005),
              Text(
                shortDescription,
                textAlign: TextAlign.center,
                style: standardText
              ),
              SizedBox(height: screenHeight * 0.010),
              Text(
                email,
                textAlign: TextAlign.center,
                style: standardText
              ),
              SizedBox(height: screenHeight * 0.025),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue[900]),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/currentChallenges');
                },
                child: Text(
                    "Ongoing Challenges",
                  style: standardText,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              Text(
                "Completed Challenges: $completedChallenges",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
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
