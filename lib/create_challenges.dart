import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'settings.dart';
import 'current_challenges.dart';
import 'main.dart';

class CreateChallenge extends StatefulWidget {
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
          children: [
            IconButton(
              icon: Icon(Icons.settings),
              color: Colors.white, // Color of the icon
              iconSize: 30, // Size of the icon
              onPressed: () {
                // Here comes the navigation to the settings page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            SizedBox(width: 8),
            Container(
              alignment: Alignment.center,
              child: Text(
                'Create your Challenge',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
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
      body: Stepper(
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
                  color: _currentStep == 0 ? Colors.indigoAccent : Colors.black,
                  fontWeight: _currentStep == 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              content: Container(
                height: 400,
                child: Column(
                  children: [
                    Container(
                      height: screenHeight * 0.05,
                      child: LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints constraints) {
                            return Stack(
                              children: [
                                TextField(
                                  textAlignVertical: TextAlignVertical.center,
                                  style: standardText.copyWith(
                                    color: Colors.black,
                                    fontSize: constraints.maxHeight * 0.33,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(
                                      // Adjust bottom padding to make space for error text
                                      bottom: constraints.maxHeight * 0.4,
                                      // You might need to fine-tune this value
                                      left: constraints.maxWidth * 0.02,
                                    ),
                                    prefix: Text('Name: '),
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
                                    border: OutlineInputBorder(),
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
                    Container(
                      height: screenHeight * 0.105,
                      child: TextFormField(
                        style: TextStyle(color: Colors.white),
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
                            borderSide: BorderSide(color: Colors.black54),
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
                  color: _currentStep == 1 ? Colors.indigoAccent : Colors.black,
                  fontWeight: _currentStep == 1 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              content: Container(
                height: 400,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50], // Background color
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.black54,
                                  width: 3,
                                ), // Rounding the corners
                              ),
                              child: Column(
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
                            SizedBox(height: 10),
                            Container(
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50], // Background color
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.pink,
                                  width: 3,
                                ), // Rounding the corners
                              ),
                              child: Column(
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
                            SizedBox(height: 10),
                            Container(
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50], // Background color
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.indigoAccent,
                                  width: 3,
                                ), // Rounding the corners
                              ),
                              child: Column(
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
                              padding: EdgeInsets.all(5),
                              margin: EdgeInsets.symmetric(vertical: 5),
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
                                          icon: Icon(Icons.remove),
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
                                          icon: Icon(Icons.add),
                                          onPressed: () {
                                            setState(() {
                                              days++;  // Increases the number of days
                                            });
                                          },
                                        ),
                                        SizedBox(width: 15,),
                                        SizedBox(
                                          width: 80,
                                          child: DropdownButtonFormField<String>(
                                            decoration: InputDecoration(
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
                                            hint: Text('Unit'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            // Second text field with dropdown menu
                            Container(
                              padding: EdgeInsets.all(5),
                              margin: EdgeInsets.symmetric(vertical: 5),
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
                                      decoration: InputDecoration(
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
                                      hint: Text('Select intensity'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            // Third text field with associated input field
                            Container(
                              padding: EdgeInsets.all(5),
                              margin: EdgeInsets.symmetric(vertical: 5),
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
                  color: _currentStep == 2 ? Colors.indigoAccent : Colors.black,
                  fontWeight: _currentStep == 2 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              content: Container(
                height: 400,
                child: Column(
                  children: [
                    SizedBox(
                      width: 300,
                      height: 50,
                      child: ElevatedButton.icon(onPressed: () {
                        print('Add friend');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddFriendToChallenge()),
                        );
                      },
                        icon: Icon(
                          Icons.add_circle_outline_sharp,
                          size: 25,
                        ),
                        label: Text(
                            'Add Friends',
                            style: TextStyle(
                              fontSize: 15,
                            )
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.pink,
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Is everything correct?',
                          style: TextStyle(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 20,),
                        SizedBox(
                          width: 150,
                          height: 40,
                          child: ElevatedButton.icon(onPressed: () {
                            print('Create Challenge');
                          },
                            label: Text(
                                'Create',
                                style: TextStyle(
                                  fontSize: 20,
                                )
                            ),
                            icon: Icon(
                              Icons.done_outline_sharp,
                              size: 20,
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.indigoAccent,
                              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Inner spacing
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Corner rounding
                  ),
                ),
                child: Icon(
                  Icons.keyboard_double_arrow_left_sharp,
                  size: 25,
                ),
              ),
              SizedBox(width: 40), // Spacing between the buttons
              ElevatedButton(
                onPressed: details.onStepContinue,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blueGrey, // Text color
                  backgroundColor: Colors.white, // Background color
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Inner spacing
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Corner rounding
                  ),
                ),
                child: Icon(
                  Icons.keyboard_double_arrow_right_sharp,
                  size: 25,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}