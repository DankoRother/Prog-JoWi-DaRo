import 'package:flutter/material.dart';
import 'main.dart';

/// A stateless widget that displays the user's account information.
class AccountPage extends StatelessWidget {
  /// The name of the user.
  final String userName;

  /// The email address of the user.
  final String email;

  /// A short description or bio of the user.
  final String shortDescription;

  /// The number of challenges the user has completed.
  final int completedChallenges;

  /// A list of interest IDs associated with the user.
  final List<int> interests;

  /// A map of all possible interests, mapping interest IDs to their names.
  final Map<int, String> allInterests;

  /// Creates an [AccountPage] with the required user information.
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
    // Obtain the screen's width and height for responsive design.
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      // Adds horizontal padding based on screen width.
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: screenHeight * 0.04),
            // Displays the user's profile picture.
            CircleAvatar(
              radius: screenHeight * 0.07,
              backgroundImage: const AssetImage('assets/images/profile_placeholder.png'),
            ),
            SizedBox(height: screenHeight * 0.022),
            // Container holding user details and actions.
            Container(
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.02,
                horizontal: screenWidth * 0.05,
              ),
              decoration: BoxDecoration(
                color: Colors.blueGrey[700],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Displays the user's name.
                  Text(
                    userName,
                    textAlign: TextAlign.center,
                    style: standardText.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: screenHeight * 0.03,
                      color: Colors.pink[600],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  // Displays the user's short description.
                  Text(
                    shortDescription,
                    textAlign: TextAlign.center,
                    style: standardText.copyWith(
                      fontSize: screenHeight * 0.02,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.010),
                  // Displays the user's email address.
                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: standardText.copyWith(
                      fontSize: screenHeight * 0.02,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  // Button to navigate to ongoing challenges.
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/currentChallenges');
                    },
                    child: Text(
                      "Ongoing Challenges",
                      style: standardText.copyWith(
                        fontSize: screenHeight * 0.022,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  // Displays the number of completed challenges.
                  Text(
                    "Completed Challenges: $completedChallenges",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenHeight * 0.022,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  // Displays the user's interests as chips.
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: interests.map((interestId) {
                      return Chip(
                        label: Text(
                          allInterests[interestId] ?? 'Unknown',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: Colors.pink[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
