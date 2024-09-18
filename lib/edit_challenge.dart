import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'date_notifier.dart';


class EditChallenge extends StatefulWidget {
  final String challengeId;// Challenge-ID als Parameter
  final int challengeProgess;

  const EditChallenge({super.key, required this.challengeId, required this.challengeProgess});

  @override
  _EditChallengeState createState() => _EditChallengeState();
}

class _EditChallengeState extends State<EditChallenge> with SingleTickerProviderStateMixin {
  final double _opacity = 1.0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  IconData _currentIcon = Icons.thumb_up_off_alt_outlined;
  late int _challengeProgress;

  // Firestore-Instanz
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Set für bereits bearbeitete Daten
  Set<String> _editableDates = Set();

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

    _loadEditableDates();
    // Initialisiere challengeProgress
    _challengeProgress = widget.challengeProgess;
  }

  Future<void> _loadEditableDates() async {
    final docRef = _firestore.collection('challenge').doc(widget.challengeId);
    final doc = await docRef.get();

    if (doc.exists) {
      final data = doc.data()!;
      final editableDatesList = List<String>.from(data['editableDates'] ?? []);
      setState(() {
        _editableDates = Set.from(editableDatesList);
      });
    }
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

    // Speichern der Daten in Firestore, nur wenn der Tag unterschiedlich ist
    _checkAndUpdateChallengeResults(icon == Icons.sentiment_satisfied_alt);

    // Warte 2 Sekunden, bevor die Seite geschlossen wird
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop(); // Schließe die Seite und navigiere zurück
    });
  }

  Future<void> _checkAndUpdateChallengeResults(bool success) async {
    final today = simulatedDate.value.toUtc().toLocal().toString().split(' ')[0];

    if (_editableDates.contains(today)) {
      print('Bereits heute aktualisiert!');
      return;
    }

    try {
      final docRef = _firestore.collection('challenge').doc(widget.challengeId);
      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({
          success ? 'successfulDays' : 'failedDays': FieldValue.increment(1),
          'lastUpdated': Timestamp.now(),
          'editableDates': FieldValue.arrayUnion([today]),
        });
        setState(() {
          _editableDates.add(today);
        });
        print('Ergebnis erfolgreich aktualisiert!');
      }
    } catch (e) {
      print('Fehler beim Aktualisieren: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = simulatedDate.value.toUtc().toLocal().toString().split(' ')[0];
    final isDateEditable = !_editableDates.contains(today);

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
                            'Day ${_challengeProgress}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Have you reached your obstacle at Day ${_challengeProgress}?',
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
                                onPressed: isDateEditable ? () {
                                  _showSmileyAnimation(Icons.sentiment_satisfied_alt);
                                } : null,
                                label: const Text(
                                  'Yes',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                icon: const Icon(Icons.thumb_up_off_alt_outlined),
                              ),
                              ElevatedButton.icon(
                                onPressed: isDateEditable ? () {
                                  _showSmileyAnimation(Icons.sentiment_dissatisfied);
                                } : null,
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
                        ],
                      ),
                    ),
                    if (_currentIcon != Icons.thumb_up_off_alt_outlined && _currentIcon != Icons.thumb_down_alt_outlined)
                      Center(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Icon(
                            _currentIcon,
                            color: _currentIcon == Icons.sentiment_satisfied_alt
                                ? Colors.pink
                                : Colors.pink,
                            size: 250,
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
