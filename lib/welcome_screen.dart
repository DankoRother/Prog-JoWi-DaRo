import 'package:flutter/material.dart';
import 'dart:async';

import 'main.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller; // Controller for managing animations
  late Animation<double> _animation; // Animation for fade effect
  double _progressValue = 0.0; // Progress value for the linear progress indicator

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller with a duration of 1 second
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this, // Use this as the ticker provider for the animation
    );

    // Create a curved animation based on the controller
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Start the animation
    _controller.forward();

    // Timer to increment progress indicator over 7 seconds
    Timer.periodic(const Duration(milliseconds: 70), (Timer timer) {
      setState(() {
        _progressValue += 0.02; // Increase progress by 2%

        // Check if progress has reached 100%
        if (_progressValue >= 1.0) {
          _progressValue = 1.0; // Limit progress to 100%
          timer.cancel(); // Stop the timer

          // Navigate to the create challenges page after the progress is complete
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => const MyHomePage(title: 'challengr - beat your habits'),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation, // Apply fade transition effect
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
    _controller.dispose(); // Dispose of the animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation, // Apply fade animation to the scaffold
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background_splasherscreen.png'), // Path to the splash screen background image
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 400, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'NOTHING IS IMPOSSIBLE',
                      style: TextStyle(
                        fontSize: 25,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 70),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: LinearProgressIndicator(
                        value: _progressValue, // Current progress value
                        backgroundColor: Colors.white54,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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