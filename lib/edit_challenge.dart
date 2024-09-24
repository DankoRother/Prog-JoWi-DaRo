import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'date_notifier.dart';

class EditChallenge extends StatefulWidget {
  final String challengeId;
  final int challengeProgess;
  final String challengeObstacle;

  const EditChallenge({super.key, required this.challengeId, required this.challengeProgess, required this.challengeObstacle});

  @override
  _EditChallengeState createState() => _EditChallengeState();
}

class _EditChallengeState extends State<EditChallenge> with SingleTickerProviderStateMixin {
  final double _opacity = 1.0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  IconData _currentIcon = Icons.thumb_up_off_alt_outlined;
  late int _challengeProgress;
  late String _challengeObstacle;

  // Firestore instance for database interaction
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Set to track already edited dates
  Set<String> _editableDates = Set();

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for fade effect
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Duration of the fade animation
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
      setState(() {}); // Rebuild UI during animation
    });

    _loadEditableDates(); // Load editable dates from Firestore
    _challengeProgress = widget.challengeProgess; // Initialize challenge progress
    _challengeObstacle = widget.challengeObstacle;
  }

  // Load editable dates from Firestore
  Future<void> _loadEditableDates() async {
    final docRef = _firestore.collection('challenge').doc(widget.challengeId);
    final doc = await docRef.get();

    if (doc.exists) {
      final data = doc.data()!;
      final editableDatesList = List<String>.from(data['editableDates'] ?? []);
      setState(() {
        _editableDates = Set.from(editableDatesList); // Update local editable dates
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up the controller when the widget is disposed
    super.dispose();
  }

  // Show smiley animation and handle challenge result
  void _showSmileyAnimation(IconData icon) {
    setState(() {
      _currentIcon = icon; // Update the icon to display
    });

    // Start fade-in animation
    _controller.reset();
    _controller.forward().then((_) {
      Future.delayed(const Duration(seconds: 1), () {
        _controller.reverse(); // Start fade-out animation
      });
    });

    // Save the result in Firestore if the date has not been updated yet
    _checkAndUpdateChallengeResults(icon == Icons.sentiment_satisfied_alt);

    // Wait for 2 seconds before closing the page
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop(); // Close the page and navigate back
    });
  }

  // Check if the result for today's date can be updated, and save to Firestore
  Future<void> _checkAndUpdateChallengeResults(bool success) async {
    final today = simulatedDate.value.toUtc().toLocal().toString().split(' ')[0];

    if (_editableDates.contains(today)) {
      print('Already updated today!');
      return; // Do nothing if the date was already updated
    }

    try {
      final docRef = _firestore.collection('challenge').doc(widget.challengeId);
      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({
          success ? 'successfulDays' : 'failedDays': FieldValue.increment(1), // Increment either success or fail count
          'lastUpdated': Timestamp.now(),
          'editableDates': FieldValue.arrayUnion([today]), // Add today's date to the editable dates
        });
        setState(() {
          _editableDates.add(today); // Update local set of editable dates
        });
        print('Result successfully updated!');
      }
    } catch (e) {
      print('Error updating result: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = simulatedDate.value.toUtc().toLocal().toString().split(' ')[0];
    final isDateEditable = !_editableDates.contains(today); // Check if today is editable

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Stack(
        children: [
          Center(
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(seconds: 1), // Smooth fade effect
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
                            'CHallenge Day ${_challengeProgress +1}', // Display current challenge progress
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 35,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Have you reached ${_challengeObstacle} today?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
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
                                  _showSmileyAnimation(Icons.sentiment_satisfied_alt); // Handle 'Yes' response
                                } : null,
                                label: const Text(
                                  'Yes',
                                  style: TextStyle(
                                    fontSize: 25,
                                  ),
                                ),
                                icon: const Icon(Icons.thumb_up_off_alt_outlined),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.pink,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 12.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: isDateEditable ? () {
                                  _showSmileyAnimation(Icons.sentiment_dissatisfied); // Handle 'No' response
                                } : null,
                                label: const Text(
                                  'No',
                                  style: TextStyle(
                                    fontSize: 25,
                                  ),
                                ),
                                icon: const Icon(Icons.thumb_down_alt_outlined),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.pink,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 12.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_currentIcon != Icons.thumb_up_off_alt_outlined && _currentIcon != Icons.thumb_down_alt_outlined)
                      Center(
                        child: FadeTransition(
                          opacity: _fadeAnimation, // Apply fade animation to the icon
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
                          Navigator.of(context).pop(); // Close the page when 'X' is pressed
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
