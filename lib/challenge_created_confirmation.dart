import 'package:flutter/material.dart';
import 'dart:async';
import 'package:confetti/confetti.dart';

class ChallengeCreatedConfirmation extends StatefulWidget {
  final Duration duration;
  final void Function(int) onNavigate;
  final String data;

  const ChallengeCreatedConfirmation({
    super.key,
    required this.duration,
    required this.onNavigate,
    required this.data,
  });

  @override
  _ChallengeCreatedConfirmationState createState() => _ChallengeCreatedConfirmationState();
}

class _ChallengeCreatedConfirmationState extends State<ChallengeCreatedConfirmation> {
  double _opacity = 1.0;
  int _startTime = 4;
  late Timer _timer;
  late ConfettiController _confettiController;

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _confettiController.play(); // Startet die Konfetti-Animation
    startTimer();

    Timer(widget.duration, () {
      if (!mounted) return;

      setState(() {
        _opacity = 0.0;
      });

      Timer(const Duration(seconds: 1), () {
        widget.onNavigate(3); // Navigiere zur CurrentChallenges-Seite
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _confettiController.dispose();
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
              duration: const Duration(seconds: 1),
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
                      '"${widget.data}" was created successfully.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'You will be guided to "Your current challenges" in $_startTime seconds',
                      style: const TextStyle(
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
          // Füge hier das Konfetti-Widget hinzu
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [
                Colors.pink,
                Colors.blue.shade900,
                Colors.white,
                Colors.blueGrey,
              ], // Optional: Farben für das Konfetti definieren
              numberOfParticles: 50,
              emissionFrequency: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
