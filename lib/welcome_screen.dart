import 'package:flutter/material.dart';
import 'dart:async';

import 'main.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // progrss indicator runs 7 seconds
    Timer.periodic(const Duration(milliseconds: 70), (Timer timer) {
      setState(() {
        _progressValue += 0.02; //lifts the progress by 2 %

        if (_progressValue >= 1.0) {
          _progressValue = 1.0; // limit progress to 100 %
          timer.cancel();
          // navigate to create challenges page
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => const MyHomePage(title: 'challengr - beat your habits'),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background_splasherscreen.png'), // Path to the image
              fit: BoxFit.cover, // Image should fill the entire screen
            ),
          ),
          child: Center(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 400, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo or other widget
                    const Text(
                      'NOTHING IS IMPOSSIBLE',
                      style: TextStyle(
                        fontSize: 25,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 50,),
                    const SizedBox(height: 20), // Abstand zwischen Text und Progress Indicator
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0), // Padding für den Progress Indicator
                      child: LinearProgressIndicator(
                        value: _progressValue,
                        backgroundColor: Colors.white54, // Hintergrundfarbe des Indikators
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), // Farbe des Fortschritts
                      ),
                    ),
                  ],
                ),
              )
          ),
        ),
      ),
    );
  }
}