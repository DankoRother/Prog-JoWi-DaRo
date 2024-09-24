import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'accountController.dart';
import 'register.dart';
import 'authentication_provider.dart'; // Make sure to import your AuthProvider
import 'main.dart';
import 'interest_selection.dart';
import 'myUser.dart'; // Make sure to import your MyUserData class

class RegisterDetailsPage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final String tempUsername;
  final String tempPassword;
  final Map<int, String> allInterests;
  final VoidCallback onRegistrationComplete; // Add this callback for registration completion

  const RegisterDetailsPage({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
    required this.tempUsername,
    required this.tempPassword,
    required this.allInterests,
    required this.onRegistrationComplete, // Add this to the constructor
  }) : super(key: key);

  @override
  _RegisterDetailsPageState createState() => _RegisterDetailsPageState();
}

// For better register performance
bool isRegistering = false;
class _RegisterDetailsPageState extends State<RegisterDetailsPage> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController shortDescriptionController = TextEditingController();
  List<int> selectedInterests = [];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      body: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.03),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: widget.screenHeight * 0.04),
                  CircleAvatar(
                    radius: widget.screenHeight * 0.07,
                    backgroundImage: const AssetImage(
                        'assets/images/profile_placeholder.png'), // Replace with actual image or remove if not needed
                  ),
                  SizedBox(height: widget.screenHeight * 0.022),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: widget.screenHeight * 0.012,
                      horizontal: widget.screenWidth * 0.014,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        // Editable name field
                        TextField(
                          controller: userNameController,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: standardText.copyWith(
                            fontSize: standardText.fontSize! * 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter your name',
                          ),
                        ),
                        SizedBox(height: widget.screenHeight * 0.001),
                        // Editable email field
                        TextField(
                          controller: emailController,
                          textAlign: TextAlign.center,
                          style: standardText.copyWith(
                            fontWeight: FontWeight.normal,
                            color: Colors.grey[800],
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            filled: true,
                            fillColor: Colors.blueGrey[300],
                          ),
                        ),
                        SizedBox(height: widget.screenHeight * 0.001),
                        // Short description field
                        TextField(
                          controller: shortDescriptionController,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          maxLength: 200,
                          style: standardText.copyWith(
                            fontWeight: FontWeight.normal,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter a short description about yourself',
                            filled: true,
                            fillColor: Colors.blueGrey[300],
                          ),
                        ),

                        SizedBox(height: widget.screenHeight * 0.025),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Display and edit interests
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: selectedInterests.map((interestId) {
                                return Chip(
                                  label: Text(widget.allInterests[interestId]!), // Use widget.allInterests
                                  backgroundColor: Colors.blueGrey[300],
                                  onDeleted: () {
                                    setState(() {
                                      selectedInterests.remove(interestId);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            SizedBox(height: widget.screenHeight * 0.015),
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  final List<int>? newSelectedInterests =
                                  await showDialog<List<int>>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return _buildInterestSelectionDialog(
                                          context, selectedInterests);
                                    },
                                  );

                                  if (newSelectedInterests != null &&
                                      newSelectedInterests.isNotEmpty) {
                                    setState(() {
                                      selectedInterests = newSelectedInterests;
                                      selectedInterests = selectedInterests.sublist(
                                        0,
                                        selectedInterests.length > 3
                                            ? 3
                                            : selectedInterests.length,
                                      );
                                    });

                                    // Get the current user data from the provider
                                    final MyUserData? currentUser = authProvider.currentUser;

                                    if (currentUser != null) {
                                      // Update the local _currentUser object in the provider
                                      authProvider.updateUserInterests(newSelectedInterests);
                                    } else {
                                      // Handle the case where the user is not logged in (maybe show an error)
                                      print('User not logged in. Cannot update interests.');
                                    }
                                  }
                                } catch (e) {
                                  // Handle errors that might occur during the update
                                  print('Error updating user interests: $e');
                                  // Consider rethrowing the exception or showing an error message to the user
                                }
                              },
                              child: Text('Add interests'),
                            ),
                            SizedBox(height: widget.screenHeight * 0.015),
                            // Complete Registration button
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.blue[900]),
                              ),
                              onPressed: isRegistering
                                  ? null // Disable the button while registering
                                  : () async {
                                setState(() {
                                  isRegistering = true; // Disable the button
                                });

                                await authProvider.attemptRegister(
                                  context,
                                  widget.tempUsername,
                                  widget.tempPassword,
                                  userNameController.text,
                                  emailController.text,
                                  shortDescriptionController.text,
                                  selectedInterests,
                                      () {
                                    widget.onRegistrationComplete(); // Trigger the callback to navigate to the Account page
                                  },
                                );

                                setState(() {
                                  isRegistering = false; // Re-enable the button
                                });
                              },
                              child: Text(
                                "Complete Registration",
                                textAlign: TextAlign.center,
                                style: standardText,
                              ),
                            ),

                          ],
                        ),
                        SizedBox(height: widget.screenHeight * 0.015),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
      ),
    );
  }

  Widget _buildInterestSelectionDialog(BuildContext context,
      List<int> dialogSelectedInterests) {
    return InterestSelectionDialog(
        allInterests: widget.allInterests,
        selectedInterests: dialogSelectedInterests
    );
  }
}