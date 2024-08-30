import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';


class EditChallenge extends StatefulWidget {
  @override
  _EditChallengeState createState() => _EditChallengeState();
}

class _EditChallengeState extends State<EditChallenge> {
  double _opacity = 1.0;
  int day = 10;
  String? _responseMessage;

  void _updateResponseMessage(String message) {
    setState(() {
      _responseMessage = message;
    });

    // Warte 2 Sekunden, bevor die Seite geschlossen wird
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Schließe die Seite und navigiere zurück
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Stack(
        children: [
          Center(
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: Duration(seconds: 1),
              child: Container(
                width: 350,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Day $day',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Have you reached your obstacle at Day $day?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 50),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  _updateResponseMessage('Great! Keep going!');
                                },
                                label: Text(
                                  'Yes',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                icon: Icon(Icons.thumb_up_off_alt_outlined),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _updateResponseMessage('Maybe next time :(');
                                },
                                label: Text(
                                  'No',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                icon: Icon(Icons.thumb_down_alt_outlined),
                              ),
                            ],
                          ),
                          if (_responseMessage != null) ...[
                            SizedBox(height: 30),
                            Text(
                              _responseMessage!,
                              style: TextStyle(
                                color: Colors.white, // Farbe der Nachricht
                                fontSize: 20, // Schriftgröße
                                fontStyle: FontStyle.italic, // Kursiv
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



