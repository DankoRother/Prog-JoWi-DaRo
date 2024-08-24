import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'settings.dart';

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
              color: Colors.white, // Farbe des Icons
              iconSize: 30, // Größe des Icons
              onPressed: () {
                // Hier kommt die Navigation zur Einstellungsseite
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
      body: ListView(
        padding: EdgeInsets.all(16.0), // Abstand am Rand der Liste
        children: List.generate(10, (index) {
          return Container(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(vertical: 10.0), // Abstand zwischen den Containern
            width: 300,
            height: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink, Colors.white], // Farben des Verlaufs
                begin: Alignment.topLeft, // Anfangspunkt des Verlaufs
                end: Alignment.bottomRight, // Endpunkt des Verlaufs
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.black54,
                width: 3,
              ),// Ecken abrunden
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
                                    color: Colors.blueGrey[50], // Hintergrundfarbe
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.black54,
                                      width: 3,
                                    ),// Abrundung der Ecken
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.timeline_sharp, color: Colors.black54), // Beispiel-Icon für "Time"
                                          SizedBox(width: 10), // Abstand zwischen Icon und Text
                                          Text(
                                            'Progress',
                                            style: TextStyle(fontSize: 20), // Textstil
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
                                    color: Colors.blueGrey[50], // Hintergrundfarbe
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.pink,
                                      width: 3,
                                    ),// Abrundung der Ecken
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.timelapse_sharp, color: Colors.pink), // Beispiel-Icon für "Intensity"
                                          SizedBox(width: 10), // Abstand zwischen Icon und Text
                                          Text(
                                            'Day´s left',
                                            style: TextStyle(fontSize: 20), // Textstil
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
                                    color: Colors.blueGrey[50], // Hintergrundfarbe
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.indigoAccent,
                                      width: 3,
                                    ),// Abrundung der Ecken
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.numbers_sharp, color: Colors.indigoAccent), // Beispiel-Icon für "Obstacle"
                                          SizedBox(width: 10), // Abstand zwischen Icon und Text
                                          Text(
                                            'Rank',
                                            style: TextStyle(fontSize: 20), // Textstil
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
            )
          );
        }),
      ),
    );
  }
}


