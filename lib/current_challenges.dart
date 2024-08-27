import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'settings.dart';
import 'edit_challenge.dart';

class CurrentChallenges extends StatefulWidget {
  @override
  _CurrentChallengesState createState() => _CurrentChallengesState();
}

class _CurrentChallengesState extends State<CurrentChallenges> {
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
                'Your current Challenges',
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/account_background.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7),
                BlendMode.dstATop,)
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16.0), // Spacing at the edge of the list
          children: List.generate(5, (index) {
            return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      opaque: false, // Seite wird transparent
                      pageBuilder: (BuildContext context, _, __) =>
                          EditChallenge(),
                    ),
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(vertical: 10.0), // Spacing between the containers
                  width: 300,
                  height: 280,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.pink, Colors.white], // Colors of the gradient
                      begin: Alignment.topLeft, // Starting point of the gradient
                      end: Alignment.bottomRight, // Ending point of the gradient
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.black54,
                      width: 3,
                    ), // Round the corners
                  ),
                  child: Container(
                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 15.0, right: 15.0,),
                    child: Column(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Name of Challenge $index',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15,),
                        Container(
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
                                                Icon(Icons.timeline_sharp, color: Colors.black54), // Example icon for "Time"
                                                SizedBox(width: 10), // Spacing between icon and text
                                                Text(
                                                  'Progress',
                                                  style: TextStyle(fontSize: 20), // Text style
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 5),
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
                                                Icon(Icons.timelapse_sharp, color: Colors.pink), // Example icon for "Intensity"
                                                SizedBox(width: 10), // Spacing between icon and text
                                                Text(
                                                  'Day´s left',
                                                  style: TextStyle(fontSize: 20), // Text style
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 5),
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
                                                Icon(Icons.numbers_sharp, color: Colors.indigoAccent), // Example icon for "Obstacle"
                                                SizedBox(width: 10), // Spacing between icon and text
                                                Text(
                                                  'Rank',
                                                  style: TextStyle(fontSize: 20), // Text style
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // Erstes Textfeld mit zugehörigem Input-Feld
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        margin: EdgeInsets.symmetric(vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.blueGrey[50], // Hintergrundfarbe
                                          borderRadius: BorderRadius.circular(10), // Abrundung der Ecken
                                        ),
                                        child: Column(),
                                      ),
                                      SizedBox(height: 7),
                                      // Zweites Textfeld mit Dropdown-Menü
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        margin: EdgeInsets.symmetric(vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.blueGrey[50],
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Column(),
                                      ),
                                      SizedBox(height: 7),
                                      // Drittes Textfeld mit zugehörigem Input-Feld
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        margin: EdgeInsets.symmetric(vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.blueGrey[50],
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Column(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
            );
          }),
        ),
      ),
    );
  }
}