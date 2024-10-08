import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'date_notifier.dart';

class EditChallenge extends StatefulWidget {
  final String challengeId; // Unique identifier for the challenge
  final int challengeProgess; // Progress of the challenge
  final String challengeObstacle; // The specific obstacle of the challenge

  const EditChallenge({
    super.key,
    required this.challengeId,
    required this.challengeProgess,
    required this.challengeObstacle,
  });

  @override
  _EditChallengeState createState() => _EditChallengeState();
}

class _EditChallengeState extends State<EditChallenge> with SingleTickerProviderStateMixin {
  final double _opacity = 1.0; // Opacity value for fade effect
  late AnimationController _controller; // Animation controller for managing animations
  late Animation<double> _fadeAnimation; // Animation for fade effect
  IconData _currentIcon = Icons.thumb_up_off_alt_outlined; // Icon to show user feedback
  late int _challengeProgress; // Current progress of the challenge
  late String _challengeObstacle; // Current challenge obstacle

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
        curve: Curves.easeInOut, // Smooth easing for the animation
      ),
    )..addListener(() {
      setState(() {}); // Rebuild UI during animation
    });

    _loadEditableDates(); // Load editable dates from Firestore
    _challengeProgress = widget.challengeProgess; // Initialize challenge progress
    _challengeObstacle = widget.challengeObstacle; // Initialize challenge obstacle
  }

  // Load editable dates from Firestore
  Future<void> _loadEditableDates() async {
    final docRef = _firestore.collection('challenge').doc(widget.challengeId); // Reference to the challenge document
    final doc = await docRef.get(); // Get the document data

    if (doc.exists) {
      final data = doc.data()!;
      final editableDatesList = List<String>.from(data['editableDates'] ?? []); // Extract editable dates
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
      _currentIcon = icon; // Update the icon to display the user's response
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
    final today = simulatedDate.value.toUtc().toLocal().toString().split(' ')[0]; // Get today's date

    if (_editableDates.contains(today)) {
      print('Already updated today!'); // Log if the date has already been updated
      return; // Do nothing if the date was already updated
    }

    try {
      final docRef = _firestore.collection('challenge').doc(widget.challengeId); // Reference to the challenge document
      final doc = await docRef.get(); // Get the document data

      if (doc.exists) {
        await docRef.update({
          success ? 'successfulDays' : 'failedDays': FieldValue.increment(1), // Increment either success or fail count
          'lastUpdated': Timestamp.now(), // Update the timestamp of the last update
          'editableDates': FieldValue.arrayUnion([today]), // Add today's date to the editable dates
        });
        setState(() {
          _editableDates.add(today); // Update local set of editable dates
        });
        print('Result successfully updated!'); // Log successful update
      }
    } catch (e) {
      print('Error updating result: $e'); // Log any errors that occur during update
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = simulatedDate.value.toUtc().toLocal().toString().split(' ')[0]; // Get today's date
    final isDateEditable = !_editableDates.contains(today); // Check if today is editable

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5), // Background color with opacity
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
                  color: Colors.blue[900], // Background color for the container
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Challenge Day ${_challengeProgress}', // Display current challenge progress
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 35,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Have you reached ${_challengeObstacle} today?', // Prompt user for challenge status
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
                            color: Colors.pink, // Icon color
                            size: 250, // Icon size
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
