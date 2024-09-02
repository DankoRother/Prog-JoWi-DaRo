import 'package:flutter/material.dart';

import 'current_challenges.dart';
import 'main.dart';

class MyAccountState extends StatefulWidget {
  const MyAccountState({super.key});

  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccountState> {
  String userName = 'Danko Rother';
  String email = 'john.doe@example.com';
  String shortDescription = 'Avid runner and coffee enthusiast.';
  int completedChallenges = 5; // TODO: Implement proper database logic here
  late double screenWidth;
  late double screenHeight;
  bool isLoggedIn = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final Map<int, String> allInterests = {
    1: '🏃 Laufen',
    2: '☕ Kaffee',
    3: '📚 Lesen',
    4: '🏋️‍♀️ Gym',
    5: '🧘 Yoga',
    6: '🎸 Musik',
    7: '🎨 Kunst',
    8: '✈️ Reisen',
    9: '👨‍🍳 Kochen',
  };

  // User's selected interests (list of IDs)
  List<int> interests = [1, 2, 3];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink, Colors.blueGrey.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: isLoggedIn ? const Text("My Account") : null,
        actions: isLoggedIn
            ? [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    child: Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.15,
                            horizontal: screenWidth * 0.1),
                        child: _buildEditAccountPage(context),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isLoggedIn = false;
              });
            },
            icon: const Icon(Icons.logout),
          ),
        ]
            : null,
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          screenWidth = constraints.maxWidth;
          screenHeight = constraints.maxHeight;
          return Center(
            child: isLoggedIn
                ? _buildAccountPage(screenWidth, screenHeight)
                : _buildLoginPage(screenWidth, screenHeight),
          );
        },
      ),
    );
  }

  Widget _buildAccountPage(double screenWidth, double screenHeight) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: screenHeight * 0.04),
        CircleAvatar(
          radius: screenHeight * 0.07,
          backgroundImage: const AssetImage(
              'assets/images/profile_placeholder.png'),
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
                    backgroundColor:
                    WidgetStateProperty.all(Colors.blue[900])),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CurrentChallenges()),
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

              // Display interests
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

  Widget _buildLoginPage(double screenWidth, double screenHeight) {
    void attemptLogin() {
      if (_usernameController.text == '123' &&
          _passwordController.text == '123') {
        setState(() {
          isLoggedIn = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.pink[700],
            content: Text('Invalid username or password'),
          ),
        );
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              onSubmitted: (_) => attemptLogin(),
            ),
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.blue[900]),
            ),
            onPressed: () {
              attemptLogin();
            },
            child: Text(
              'Login',
              style: standardText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditAccountPage(BuildContext context) {
    final TextEditingController _userNameController =
    TextEditingController(text: userName);
    final TextEditingController _emailController =
    TextEditingController(text: email);
    final TextEditingController _shortDescriptionController =
    TextEditingController(text: shortDescription);
    List<int> selectedInterests = List.from(
        interests); // Initialize with current interests

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Account"),
      ),
      // Wrap the body with StatefulBuilder
      body: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: screenHeight * 0.04),
                CircleAvatar(
                  radius: screenHeight * 0.07,
                  backgroundImage: const AssetImage(
                      'assets/images/profile_placeholder.png'),
                ),
                SizedBox(height: screenHeight * 0.022),
                Container(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.012,
                      horizontal: screenWidth * 0.014),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                      children: [
                        // Editable username field
                        TextField(
                          controller: _userNameController,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: standardText.copyWith(
                            fontSize: standardText.fontSize! * 1.4,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter new username',
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        // Editable email field
                        TextField(
                          controller: _emailController,
                          textAlign: TextAlign.center,
                          style: standardText.copyWith(color: Colors.grey),
                          decoration: const InputDecoration(
                            hintText: 'Enter new email',
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        // Short description field
                        TextField(
                          controller: _shortDescriptionController,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          maxLength: 200,
                          // Allow only one line for the description
                          style: standardText.copyWith(color: Colors.grey),
                          decoration: const InputDecoration(
                            hintText: 'Enter a short description about yourself',
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.025),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Submit Changes button
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(Colors.blue[900]),
                              ),
                              onPressed: () {
                                // Update user data and interests in the main _MyAccountState
                                this.setState(() { // Use 'this' to refer to the _MyAccountState
                                  userName = _userNameController.text;
                                  email = _emailController.text;
                                  shortDescription = _shortDescriptionController.text;
                                  interests = List.from(selectedInterests); // Update the main interests list
                                });

                                Navigator.pop(context);
                              },
                              child: Text(
                                textAlign: TextAlign.center,
                                "Submit Changes",
                                style: standardText,
                              ),
                            ),

                          ],
                        ),

                        SizedBox(height: screenHeight * 0.015),
                        // Display and edit interests
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: selectedInterests.map((interestId) {
                            return Chip(
                              label: Text(allInterests[interestId]!),
                              backgroundColor: Colors.blueGrey[300],
                              onDeleted: () {
                                // Remove interest from the local selectedInterests list and rebuild the widget
                                setState(() {
                                  selectedInterests.remove(interestId);
                                });
                              },
                            );
                          }).toList(),
                        ),
                        SizedBox(height: screenHeight * 0.015),

                        ElevatedButton(
                          onPressed: () async {
                            final List<int>? newSelectedInterests = await showDialog<List<int>>(
                              context: context,
                              builder: (BuildContext context) {
                                // Pass the current selectedInterests to the dialog
                                return _buildInterestSelectionDialog(context, selectedInterests);
                              },
                            );

                            // If the user selected new interests, update the local state
                            if (newSelectedInterests != null && newSelectedInterests.isNotEmpty) {
                              setState(() {
                                selectedInterests = newSelectedInterests;
                                // Ensure we don't exceed the maximum of 3 interests
                                selectedInterests = selectedInterests.sublist(0, selectedInterests.length > 3 ? 3 : selectedInterests.length);
                              });
                            }
                          },
                          child: Text('Add Interest'),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                      ]),
                ),
              ],
            );
          }),
    );
  }

  // Dialog to select interests
  Widget _buildInterestSelectionDialog(BuildContext context,
      List<int> dialogSelectedInterests) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return AlertDialog(
          title: const Text('Select Interests'),
          content: SingleChildScrollView(
            child: Column(
              children: allInterests.entries
                  .where((entry) => !dialogSelectedInterests.contains(entry.key)) // Use dialogSelectedInterests here
                  .map((entry) {
                return CheckboxListTile(
                  title: Text(entry.value),
                  value: dialogSelectedInterests.contains(entry.key), // Use dialogSelectedInterests here
                  onChanged: (bool? value) {
                    setState(() {
                      if (value!) {
                        dialogSelectedInterests.add(entry.key);
                      } else {
                        dialogSelectedInterests.remove(entry.key);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(dialogSelectedInterests);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}