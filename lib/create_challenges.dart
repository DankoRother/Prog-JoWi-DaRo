import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'authentication_provider.dart';
import 'current_challenges.dart';
import 'main.dart';
import 'challenge_created_confirmation.dart';
import 'addfriend_createchallenge.dart';
import 'logInPrompt.dart';
import 'appBar.dart';

class CreateChallenge extends StatefulWidget {
  const CreateChallenge({super.key});

  @override
  CreateChallengeState createState() => CreateChallengeState();
}

class CreateChallengeState extends State<CreateChallenge> {
  final _formKey = GlobalKey<FormState>();
  int currentStep = 0;
  int _duration = 7;
  String? _selectedUnit = 'D';
  String? _selectedFrequency = 'daily';
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  late TextEditingController _obstacle = TextEditingController();

  //checks if every field contains an information
  Future checkMissingValues() async {
    if (_obstacle.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.pink,
          content: Text('Do not forget to add an obstacle in your challenge'),
        ),
      );
      return false;
    }
    return true;
  }

  //save data in firestore
  Future<void> _saveChallenge() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You need to be logged in to create a challenge')),
      );
      return;
    }

    String title = _title.text;
    String description = _description.text;
    String obstacle = _obstacle.text;
    String? frequency = _selectedFrequency;

    //calculate the final Duration in days based on the user input
    int factor;
    switch (_selectedUnit) {
      case 'D': factor = 1; break;
      case 'W': factor = 7; break;
      case 'M': factor = 30; break;
      case 'Y': factor = 365; break;
      default: factor = 1;
    }

    int finalDuration = _duration * factor;

    try {
      // Add challenge to Firestore
      final newChallengeRef = await FirebaseFirestore.instance.collection('challenge').add({
        'title': title,
        'description': description,
        'finalDuration': finalDuration,
        'frequency': frequency,
        'obstacle': obstacle,
        'createdAt': Timestamp.now(),
        'userId': user.uid,  // Associate the challenge with the user
      });

      // Add the challenge ID to the user's list of challenges
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'challenges': FieldValue.arrayUnion([newChallengeRef.id]), // Append the new challenge to the user's challenges
      });
      // Navigate after success
      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (context, animation, secondaryAnimation) => ChallengeCreatedConfirmation(
            data: _title.text,
            duration: const Duration(seconds: 5),
            onNavigate: (int selectedIndex) {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CurrentChallenges()),
              );
            },
          ),
        ),
      );

      //making sure that the fields get cleared after saving the challenge successfully
      Future.delayed(const Duration(seconds: 5), () {
        _title.clear();
        _description.clear();
        _obstacle.clear();
        setState(() {
          _duration = 7;
          _selectedUnit = 'D';
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error creating the challenge: $e'),
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    authProvider.checkLoginStatus();
    final isLoggedIn = authProvider.isLoggedIn;

    return Scaffold(
      appBar: buildAppBar(
        context: context,
        loggedInTitle: 'Create your new Challenge',
        loggedOutTitle: 'Create new Challenge',
      ),
      body: isLoggedIn ? _buildChallengeForm() : LogInPrompt(),
    );
  }

  //widget for challenge creation
  Widget _buildChallengeForm() {
    return Stepper(
      currentStep: currentStep,
      onStepContinue: () {
        if (currentStep < 2) {
          setState(() {
            currentStep++;
          });
        }
      },
      onStepCancel: () {
        if (currentStep > 0) {
          setState(() {
            currentStep--;
          });
        }
      },
      steps: [
        //Step 1: add name and descritpion
        Step(
          title: Text(
            'Start',
            style: TextStyle(
              color: currentStep == 0 ? Colors.blue[900] : Colors.black,
              fontWeight: currentStep == 0 ? FontWeight.bold : FontWeight
                  .normal,
            ),
          ),
          content: SizedBox(
            height: 400,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Name:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenHeight * 0.03,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  SizedBox(
                    height: screenHeight * 0.15,
                    child: TextFormField(
                      controller: _title,
                      maxLength: 50,
                      textAlignVertical: TextAlignVertical.center,
                      style: standardText.copyWith(
                        color: Colors.white,
                        fontSize: screenHeight *
                            0.03,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.02,
                        ),
                        suffixIcon: Icon(
                          Icons.draw_outlined,
                          color: Colors.white,
                          size: screenHeight * 0.02,
                        ),
                        hintText: 'Give your Challenge a name',
                          hintStyle: standardText.copyWith(
                            color: Colors.white,
                            fontSize: screenHeight * 0.03,
                            fontStyle: FontStyle.italic
                          ),
                        border: const OutlineInputBorder(),
                        fillColor: Colors.pink,
                        filled: true,
                      ),
                      //making sure that there´s an input
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please provide a name for your challenge.';
                        }
                        return null;
                      },
                    ),
                  ),
                  Text(
                    'Description:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenHeight * 0.03,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  SizedBox(
                    height: screenHeight * 0.15,
                    child: TextFormField(
                      controller: _description,
                      maxLength: 100,
                      style: standardText.copyWith(
                        color: Colors.white,
                        fontSize: screenHeight *
                            0.03,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.02,
                        ),
                        suffixIcon: Icon(
                          Icons.draw_outlined,
                          color: Colors.white,
                          size: screenHeight * 0.02,
                        ),
                        hintText: 'What is the purpose of this Challenge?',
                        hintStyle: standardText.copyWith(
                            color: Colors.white,
                            fontSize: screenHeight * 0.03,
                            fontStyle: FontStyle.italic
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(screenWidth *
                              0.01),
                          borderSide: const BorderSide(color: Colors.black54),
                        ),
                        fillColor: Colors.pink,
                        filled: true,
                      ),
                      //settings for input management at description field
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      minLines: 4,
                      //making sure there´s an input
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please describe the challenge.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        //Step 2: add parameters to challenge
        Step(
            title: Text(
              'Commit',
              style: TextStyle(
                color: currentStep == 1 ? Colors.blue[900] : Colors.black,
                fontWeight: currentStep == 1 ? FontWeight.bold : FontWeight
                    .normal,
              ),
            ),
            content: SizedBox(
              height: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.black54,
                                width: 3,
                              ),
                            ),
                            child: const Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        color: Colors.black54
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Time',
                                      style: TextStyle(
                                          fontSize: 20
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                    '(Duration?)',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                    )
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.pink,
                                width: 3,
                              ),
                            ),
                            child: const Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.whatshot, color: Colors.pink),
                                    SizedBox(width: 10),
                                    Text(
                                      'Intensity',
                                      style: TextStyle(
                                          fontSize: 20
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                    '(How often?)',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                    )
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.blue.shade900,
                                width: 3,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.sports_kabaddi,
                                        color: Colors.blue.shade900
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Obstacle',
                                      style: TextStyle(
                                          fontSize: 20
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(
                                    '(Objective?)',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                    )
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50],
                              borderRadius: BorderRadius.circular(
                                  10),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: Row(
                                    children: [
                                      // Minus button
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () {
                                          setState(() {
                                            if (_duration >
                                                0) _duration--; // Decreases the number of days
                                          });
                                        },
                                      ),
                                      Expanded(
                                        child: Text(
                                          _duration.toString(),
                                          // Displays the current value of duration
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      // Plus button
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          setState(() {
                                            _duration++; // Increases the number of days
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 15,),
                                      SizedBox(
                                        width: 80,
                                        child: DropdownButtonFormField<String>(
                                          value: _selectedUnit,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                          items: <String>['D', 'W', 'M', 'Y']
                                              .map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (newValue) {
                                            setState(() {
                                              _selectedUnit =
                                                  newValue; // Aktualisiere den Wert im State
                                            });
                                          },
                                          hint: const Text('Unit'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(5),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedFrequency,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                    items: <String>[
                                      'daily',
                                      'weekly',
                                      'biweekly'
                                    ].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        _selectedFrequency = newValue;

                                        if (newValue == 'weekly' || newValue == 'biweekly') {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Please note that $newValue is mocked and does not work. (You can edit the challenge daily.)'),
                                              duration: Duration(seconds: 4),
                                            ),
                                          );
                                        }
                                      });
                                    },
                                    hint: const Text('Select intensity'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(5),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: TextField(
                                    controller: _obstacle,
                                    maxLength: 20,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Enter obstacle',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )
        ),
        //Step 3: adding friends and creating challenge
        Step(
            title: Text(
              'Create',
              style: TextStyle(
                color: currentStep == 2 ? Colors.blue[900] : Colors.black,
                fontWeight: currentStep == 2 ? FontWeight.bold : FontWeight
                    .normal,
              ),
            ),
            content: SizedBox(
              height: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    height: 50,
                    child: ElevatedButton.icon(onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddFriendToChallenge()),
                      );
                    },
                      icon: const Icon(
                        Icons.add_circle_outline_sharp,
                        size: 25,
                      ),
                      label: const Text(
                          'Add Friends',
                          style: TextStyle(
                            fontSize: 15,
                          )
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.pink,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Is everything correct?',
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40,),
                  SizedBox(
                    width: 200,
                    height: 40,
                    //calls the savechallenge method
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        bool allFieldsValid = await checkMissingValues();
                        if (allFieldsValid) {
                          await _saveChallenge();
                        }
                      },
                      label: const Text(
                        'Create',
                        style: TextStyle(fontSize: 20),
                      ),
                      icon: const Icon(
                        Icons.done_outline_sharp,
                        size: 20,
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue[900],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
        ),
      ],
      type: StepperType.horizontal,
      controlsBuilder: (BuildContext context, ControlsDetails details) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: details.onStepCancel,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blueGrey, // Text color
                backgroundColor: Colors.white, // Background color
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Corner rounding
                ),
              ),
              child: const Icon(
                Icons.keyboard_double_arrow_left_sharp,
                size: 25,
              ),
            ),
            const SizedBox(width: 40),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  details.onStepContinue!();
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blueGrey,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Icon(
                Icons.keyboard_double_arrow_right_sharp,
                size: 25,
              ),
            ),
          ],
        );
      },
    );
  }
}