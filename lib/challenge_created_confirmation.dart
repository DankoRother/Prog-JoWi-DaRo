import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'dart:async';

import 'current_challenges.dart';
import 'main.dart';

class ChallengeCreatedConfirmation extends StatefulWidget {
  final Duration duration;

  ChallengeCreatedConfirmation({required this.duration});

  @override
  _ChallengeCreatedConfirmationState createState() => _ChallengeCreatedConfirmationState();
}

class _ChallengeCreatedConfirmationState extends State<ChallengeCreatedConfirmation> {
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();

    // start fadeout process after complete duration
    Timer(widget.duration, () {
      setState(() {
        _opacity = 0.0;
      });

      // close page after fade out
      Timer(Duration(seconds: 1), () {
        Navigator.of(context).pop();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [ // container which is not transparent
          Center(
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: Duration(seconds: 1), // time for fade out
              child: Container(
                width: 400,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.indigoAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Your Challenge "Name of Challenge" was created successfully.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontStyle: FontStyle.italic,),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}