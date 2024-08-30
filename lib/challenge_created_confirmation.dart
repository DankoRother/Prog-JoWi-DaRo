import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'dart:async';

import 'current_challenges.dart';
import 'main.dart';
import 'create_challenges.dart';

class ChallengeCreatedConfirmation extends StatefulWidget {
  final Duration duration;
  final void Function(int) onNavigate;

  ChallengeCreatedConfirmation({required this.duration, required this.onNavigate});

  @override
  _ChallengeCreatedConfirmationState createState() => _ChallengeCreatedConfirmationState();
}

class _ChallengeCreatedConfirmationState extends State<ChallengeCreatedConfirmation> {
  double _opacity = 1.0;
  int _startTime = 4;
  late Timer _timer;

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_startTime == 0) {
        setState(() {
          _timer.cancel();
        });
      } else {
        setState(() {
          _startTime--;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();

    Timer(widget.duration, () {
      if (!mounted) return;

      setState(() {
        _opacity = 0.0;
      });

      Timer(Duration(seconds: 1), () {
        // Navigiere zur CurrentChallenges-Seite
        widget.onNavigate(3);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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
                width: 400,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '"Name of Challenge" was created successfully.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'You will be guided to "Your current challenges" in $_startTime seconds',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
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



