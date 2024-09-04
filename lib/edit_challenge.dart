import 'package:flutter/material.dart';

class EditChallenge extends StatefulWidget {
  const EditChallenge({super.key});

  @override
  _EditChallengeState createState() => _EditChallengeState();
}

class _EditChallengeState extends State<EditChallenge> with SingleTickerProviderStateMixin {
  final double _opacity = 1.0;
  int day = 10;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  IconData _currentIcon = Icons.thumb_up_off_alt_outlined;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Dauer der Fade-Animation
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSmileyAnimation(IconData icon) {
    setState(() {
      _currentIcon = icon;
    });

    // Starte die Fade-Animation
    _controller.reset();
    _controller.forward().then((_) {
      Future.delayed(const Duration(seconds: 1), () {
        _controller.reverse(); // Starte die Ausblend-Animation
      });
    });

    // Warte 2 Sekunden, bevor die Seite geschlossen wird
    Future.delayed(const Duration(seconds: 3), () {
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
              duration: const Duration(seconds: 1),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Have you reached your obstacle at Day $day?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 50),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  _showSmileyAnimation(Icons.sentiment_satisfied_alt);
                                },
                                label: const Text(
                                  'Yes',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                icon: const Icon(Icons.thumb_up_off_alt_outlined),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _showSmileyAnimation(Icons.sentiment_dissatisfied);
                                },
                                label: const Text(
                                  'No',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                icon: const Icon(Icons.thumb_down_alt_outlined),
                              ),
                            ],
                          ),
                          // Entfernen der Textanzeige für die Response-Nachricht
                        ],
                      ),
                    ),
                    // Sanfte Fade-In und Fade-Out Animation für das Icon
                    if (_currentIcon != Icons.thumb_up_off_alt_outlined && _currentIcon != Icons.thumb_down_alt_outlined)
                      Center(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Icon(
                            _currentIcon,
                            color: _currentIcon == Icons.sentiment_satisfied_alt
                                ? Colors.pink
                                : Colors.pink,
                            size: 250, // Größeres Icon für bessere Sichtbarkeit
                          ),
                        ),
                      ),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
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
