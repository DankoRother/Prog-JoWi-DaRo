import 'package:flutter/material.dart';

import 'settings.dart';
import 'current_challenges.dart';
import 'main.dart';
import 'challenge_created_confirmation.dart';
import 'addfriend_createchallenge.dart';

class CreateChallenge extends StatefulWidget {
  const CreateChallenge({super.key});

  @override
  _CreateChallengeState createState() => _CreateChallengeState();
}

class _CreateChallengeState extends State<CreateChallenge> {
  int _currentStep = 0;
  int days = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.center,
              child: const Text(
                'Create a new Challenge',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              color: Colors.white, // Color of the icon
              iconSize: 30, // Size of the icon
              onPressed: () {
                // Navigation to the settings page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink, Colors.blueGrey.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        /*decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/account_background.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7),
                BlendMode.dstATop,)
          ),
        ),*/ //in case we need the background image just remove the comment marks
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (step) => setState(() => _currentStep = step),
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() {
                _currentStep++;
              });
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            }
          },
          steps: [
            Step(
                title: Text(
                  'Start',
                  style: TextStyle(
                    color: _currentStep == 0 ? Colors.blue[900] : Colors.black,
                    fontWeight: _currentStep == 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                content: SizedBox(
                  height: 400,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: screenHeight * 0.05,
                        child: LayoutBuilder(
                            builder: (BuildContext context, BoxConstraints constraints) {
                              return Stack(
                                children: [
                                  TextField(
                                    textAlignVertical: TextAlignVertical.center,
                                    style: standardText.copyWith(
                                      color: Colors.white,
                                      fontSize: constraints.maxHeight * 0.33,
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(
                                        // Adjust bottom padding to make space for error text
                                        bottom: constraints.maxHeight * 0.4,
                                        // You might need to fine-tune this value
                                        left: constraints.maxWidth * 0.02,
                                      ),
                                      prefix: const Text('Name: '),
                                      prefixStyle: standardText.copyWith(
                                        color: Colors.white,
                                        fontSize: constraints.maxHeight * 0.4,
                                      ),
                                      suffixIcon: Icon(
                                        Icons.draw_outlined,
                                        color: Colors.white,
                                        size: constraints.maxHeight * 0.4,
                                      ),
                                      hintText: 'Give your challenge a fancy name!',
                                      hintStyle: standardText.copyWith(
                                        color: Colors.white,
                                        fontStyle: FontStyle.italic,
                                        fontSize: constraints.maxHeight * 0.4,
                                      ),
                                      // Remove errorText from InputDecoration
                                      border: const OutlineInputBorder(),
                                      // You can add border styling if needed
                                      fillColor: Colors.pink[700],
                                      filled: true,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: constraints.maxHeight * -0.13, // Position the error text at the bottom
                                    left: constraints.maxWidth*0.5, // Align it in the center
                                    child: Text(
                                      '* Default value!',
                                      style: standardText.copyWith(
                                        color: Colors.blue,
                                        fontSize: constraints.maxHeight * 0.2,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.105,
                        child: TextFormField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            prefixText: 'What: ',
                            prefixStyle: TextStyle(
                              color: Colors.white,
                              fontSize: screenHeight * 0.015,
                            ),
                            suffixIcon: Icon(
                              Icons.draw_outlined,
                              color: Colors.white,
                              size: screenWidth * 0.012,
                            ),
                            hintText: '(On what to compete? Tell us :))',
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                              fontSize: screenHeight * 0.015,
                            ),
                            errorText: '* Default value!',
                            errorStyle: TextStyle(
                              color: Colors.red[600],
                              fontSize: screenHeight * 0.007,
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(screenWidth * 0.012),
                              borderSide: const BorderSide(color: Colors.black54),
                            ),
                            fillColor: Colors.pink[700],
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.025,
                              horizontal: screenWidth * 0.009,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            ),
            Step(
                title: Text(
                  'Commit',
                  style: TextStyle(
                    color: _currentStep == 1 ? Colors.blue[900] : Colors.black,
                    fontWeight: _currentStep == 1 ? FontWeight.bold : FontWeight.normal,
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
                                  color: Colors.blueGrey[50], // Background color
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.black54,
                                    width: 3,
                                  ), // Rounding the corners
                                ),
                                child: const Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.access_time, color: Colors.black54), // Example icon for "Time"
                                        SizedBox(width: 10), // Spacing between icon and text
                                        Text(
                                          'Time',
                                          style: TextStyle(fontSize: 20), // Text style
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
                                  color: Colors.blueGrey[50], // Background color
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.pink,
                                    width: 3,
                                  ), // Rounding the corners
                                ),
                                child: const Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.whatshot, color: Colors.pink), // Example icon for "Intensity"
                                        SizedBox(width: 10), // Spacing between icon and text
                                        Text(
                                          'Intensity',
                                          style: TextStyle(fontSize: 20), // Text style
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
                                  color: Colors.blueGrey[50], // Background color
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.indigoAccent,
                                    width: 3,
                                  ), // Rounding the corners
                                ),
                                child: const Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.sports_kabaddi, color: Colors.indigoAccent), // Example icon for "Obstacle"
                                        SizedBox(width: 10), // Spacing between icon and text
                                        Text(
                                          'Obstacle',
                                          style: TextStyle(fontSize: 20), // Text style
                                        ),
                                      ],
                                    ),
                                    Text(
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
                              // First text field with associated input field
                              Container(
                                padding: const EdgeInsets.all(5),
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[50], // Background color
                                  borderRadius: BorderRadius.circular(10), // Rounding the corners
                                ),
                                child: Column(
                                  //crossAxisAlignment: CrossAxisAlignment.start, // Align left
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
                                                if (days > 0) days--;  // Decreases the number of days
                                              });
                                            },
                                          ),

                                          // Text field that displays the current value
                                          Expanded(
                                            child: TextField(
                                              controller: TextEditingController(text: days.toString()),
                                              readOnly: true,  // Prevents manual input
                                              textAlign: TextAlign.center,
                                              decoration: null, // Centers the text
                                            ),
                                          ),

                                          // Plus button
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed: () {
                                              setState(() {
                                                days++;  // Increases the number of days
                                              });
                                            },
                                          ),
                                          const SizedBox(width: 15,),
                                          SizedBox(
                                            width: 80,
                                            child: DropdownButtonFormField<String>(
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                              ),
                                              items: <String>['D', 'W', 'M', 'Y'].map((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                              onChanged: (newValue) {
                                                // Handle the value change here
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
                              // Second text field with dropdown menu
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
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                        ),
                                        items: <String>['daily', 'weekly', 'biweekly'].map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          // Handle the value change here
                                        },
                                        hint: const Text('Select intensity'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Third text field with associated input field
                              Container(
                                padding: const EdgeInsets.all(5),
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[50],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 200,
                                      child: TextField(
                                        decoration: InputDecoration(
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
            Step(
                title: Text(
                  'Ready?',
                  style: TextStyle(
                    color: _currentStep == 2 ? Colors.blue[900] : Colors.black,
                    fontWeight: _currentStep == 2 ? FontWeight.bold : FontWeight.normal,
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
                          print('Add friend');
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddFriendToChallenge()),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                opaque: false,
                                pageBuilder: (context, animation, secondaryAnimation) => ChallengeCreatedConfirmation(
                                  duration: const Duration(seconds: 5),
                                  onNavigate: (int selectedIndex) {
                                    Navigator.of(context).pop(); // Schließt die Bestätigungsseite

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context)
                                      => const CurrentChallenges()),
                                    );
                                  },
                                ),
                              ),
                            );
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
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Inner spacing
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Corner rounding
                    ),
                  ),
                  child: const Icon(
                    Icons.keyboard_double_arrow_left_sharp,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 40), // Spacing between the buttons
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blueGrey, // Text color
                    backgroundColor: Colors.white, // Background color
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Inner spacing
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Corner rounding
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
        ),
      ),
    );
  }
}
