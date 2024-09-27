import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'settings.dart';
import 'edit_challenge.dart';
import 'authentication_provider.dart';
import 'date_notifier.dart';
import 'logInPrompt.dart';

class CurrentChallenges extends StatefulWidget {
  const CurrentChallenges({super.key});

  @override
  _CurrentChallengesState createState() => _CurrentChallengesState();
}

class _CurrentChallengesState extends State<CurrentChallenges> {
  final FirebaseFirestore _firestore = FirebaseFirestore
      .instance; // Firestore-Instanz
  bool isLessOrEqualFilter = true;

  late Future<List<Map<String, dynamic>>> _challengesFuture;

  @override
  void initState() {
    super.initState();
    // Directly call the update function without checking for null
    _updateChallenges();
    _fetchChallenges(DateTime.now());
  }

  void _updateChallenges() {
    final currentDate = DateTime.now();
    print("A"); // Should print to console
    setState(() {
      _challengesFuture = _fetchChallenges(currentDate);
    });
  }


  Future<List<Map<String, dynamic>>> _fetchChallenges(DateTime currentDate) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    print("B");
    if (user == null || user.challenges.isEmpty) {
      return [
      ]; // Return empty list if the user is not logged in or has no challenges
    }

    // Fetch user-specific challenges from Firestore
    final challengesSnapshot = await FirebaseFirestore.instance
        .collection('challenge')
        .where(FieldPath.documentId,
        whereIn: user.challenges) // Filter by user's challenges
        .orderBy('createdAt', descending: true)
        .get();

    final List<Map<String, dynamic>> challenges = [];

    for (var doc in challengesSnapshot.docs) {
      final data = doc.data();
      final createdAt = (data['createdAt'] as Timestamp).toDate();
      final description = data['description'] as String;
      final finalDuration = data['finalDuration'] as int;
      final frequency = data['frequency'] as String;
      final obstacle = data['obstacle'] as String;
      final title = data['title'] as String;
      final successfulDays = (data['successfulDays'] ?? 0) as int;
      final failedDays = (data['failedDays'] ?? 0) as int;

      // calculate duration progress based on current date or choosen date
      final DateTime createdAtDate = DateTime(
          createdAt.year, createdAt.month, createdAt.day);
      final int daysPassed = currentDate
          .difference(createdAtDate)
          .inDays + 1;

      //making sure that duration progress is not increased after challenge is completed
      final int adjustedDaysPassed = daysPassed > finalDuration
          ? finalDuration
          : daysPassed;

      //calculating current rank for user and each challenge
      final double _successRate = adjustedDaysPassed > 0 ? successfulDays /
          adjustedDaysPassed : 0;

      String rank;
      Color rankColor;
      Icon rankIcon;

      if (_successRate >= 0.8) {
        rank = 'Gold';
        rankColor = Colors.amber;
        rankIcon = Icon(Icons.star, color: rankColor, size: 30);
      } else if (_successRate < 0.8 && _successRate >= 0.6) {
        rank = 'Silver';
        rankColor = Colors.grey.shade400;
        rankIcon = Icon(Icons.star_half, color: rankColor, size: 28);
      } else if (_successRate < 0.6 && _successRate >= 0.4) {
        rank = 'Bronze';
        rankColor = Colors.brown;
        rankIcon = Icon(Icons.emoji_events, color: rankColor, size: 26);
      } else {
        rank = 'Participant';
        rankColor = Colors.black54;
        rankIcon = Icon(Icons.person, color: rankColor, size: 24);
      }

      challenges.add({
        'id': doc.id,
        'title': title,
        'description': description,
        'finalDuration': finalDuration,
        'frequency': frequency,
        'obstacle': obstacle,
        'createdAt': createdAt,
        'adjustedDaysPassed': adjustedDaysPassed,
        'successfulDays': successfulDays,
        'failedDays': failedDays,
        'daysPassed': daysPassed,
        'rankColor': rankColor,
        'rankIcon': rankIcon,
        'currentRank': rank,
      });
    }

    return challenges;
  }

  Future<void> _deleteChallenge(String challengeId) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You need to be logged in to remove a challenge')),
        );
        return;
      }

      try {
        // Step 1: Remove the challenge ID from the user's challenges list
        await _firestore.collection('users').doc(user.uid).update({
          'challenges': FieldValue.arrayRemove([challengeId]), // Remove challenge ID from user's challenges list
        });

        // Step 2: Remove the user from the challenge's assigned users list
        await _firestore.collection('challenge').doc(challengeId).update({
          'users': FieldValue.arrayRemove([user.uid]),
        });

        // Optionally, if you're tracking the challenges a user is assigned to, you can also remove this assignment.

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Challenge removed from your list successfully')),
        );

        // Step 3: Update the challenges displayed after removing the challenge
        _updateChallenges();
        setState(() {
          _challengesFuture = _fetchChallenges(DateTime.now());
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove challenge: $e')),
        );
      }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context); // AuthProvider abrufen
    final isLoggedIn = authProvider.isLoggedIn; // Anmeldestatus abrufen

    //checks if page is lying on stack or not
    bool canPop = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  isLoggedIn
                      ? (isLessOrEqualFilter ? 'Your Active Challenges' : 'Your Completed Challenges')
                      : 'Challenges',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (isLoggedIn)
              Row(
                children: [
                  //button for archive
                  Switch(
                    value: isLessOrEqualFilter,
                    onChanged: (bool newValue) {
                      setState(() {
                        isLessOrEqualFilter = newValue;
                      });
                    },
                    activeColor: Colors.pink, // Farbe des aktiven Switch
                    inactiveThumbColor: Colors.blueGrey.shade400, // Farbe des inaktiven Switch
                    inactiveTrackColor: Colors.blueGrey.shade200, // Farbe der Switch-Spur im inaktiven Zustand
                  ),
                ],
              ),
            if (isLoggedIn)
              IconButton(
                icon: const Icon(Icons.settings),
                color: Colors.white,
                iconSize: 30,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                  );
                },
              ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink, Colors.blueGrey.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: isLoggedIn && canPop
            ? MouseRegion(
          onEnter: (PointerEnterEvent event) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.pink[900],
                content: Text('Back to previous page'),
              ),
            );
          },
          onExit: (PointerExitEvent event) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        )
            : null,
      ),

      //checks if user is logged in, otherwise build logInPrompt()
      body: isLoggedIn ? _buildChallengesPage() : LogInPrompt(),
    );
  }

  Widget _buildChallengesPage() {
    return ValueListenableBuilder<DateTime>(
      valueListenable: simulatedDate, // simluated Date is noticed here
      builder: (context, simulatedDate, child) {
        final DateTime currentDate = DateTime(simulatedDate.year, simulatedDate.month, simulatedDate.day);

        //fetch challenges based on currentDate

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchChallenges(currentDate),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error while fetching data: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No active Challenges found'));
            }

            //check if challenges are active or completed and creating array based on this topic
            final challenges = snapshot.data!.where((challenge) {
              if (isLessOrEqualFilter) {
                return challenge['daysPassed'] <= challenge['finalDuration'];
              } else {
                return challenge['daysPassed'] > challenge['finalDuration'];
              }
            }).toList();

            if (challenges.isEmpty) {
              return const Center(child: Text('No completed Challenges yet'));
            }


            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/account_background.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.dstATop),
                ),
              ),

              //build container for every challenge based on the number of challenges found in firestore
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: challenges.length,
                itemBuilder: (context, index) {
                  final challenge = challenges[index];

                  //check if challenge is completed or not
                  final completedChallenge = challenge['daysPassed'] > challenge['finalDuration'];
                  return Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade600,
                        border: Border.all(
                          color: challenges[index]['rankColor'],
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: LinearProgressIndicator(
                                value: challenge['adjustedDaysPassed'] / (challenge['finalDuration']),
                                backgroundColor: Colors.blueGrey.shade600,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 15.0, right: 15.0),
                            child: Column(
                              children: [
                              if (completedChallenge) //text for completed challenges
                              Column(
                                  children: [
                                    Text(
                                      '${challenges[index]['title']} completed at rank ${challenges[index]['currentRank']}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          fontStyle: FontStyle.italic
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 10),
                                    Icon(
                                      Icons.check_circle_outline_sharp,
                                      color: challenges[index]['rankColor'],
                                      size: 40,
                                    )
                                  ]
                                ),
                                ExpansionTile(
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        challenge['title'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      //button to get to editchallenge page and hand over the needed information
                                      ElevatedButton.icon(onPressed: completedChallenge ? null : () {
                                        Navigator.of(context).push(
                                          PageRouteBuilder(
                                            opaque: false,
                                            pageBuilder: (BuildContext context, _, __) => EditChallenge(
                                              challengeId: challenge['id'],
                                              challengeProgess: challenge['daysPassed'],
                                              challengeObstacle: challenge['obstacle'],
                                            ),
                                          ),
                                        );
                                      },
                                        icon: const Icon(
                                          Icons.fitness_center_sharp,
                                          size: 25,
                                        ),
                                        label: const Text(
                                            'Participate',
                                            style: TextStyle(
                                              fontSize: 15,
                                            )
                                        ),
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
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Note:',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Your Challenge can be found in the archive once the duration is over (${challenge['finalDuration']} + 1 Day).',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10,),
                                    Container(
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(10),
                                                    margin: const EdgeInsets.symmetric(vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(
                                                        color: Colors.blue.shade900,
                                                        width: 3,
                                                      ),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Icon(Icons.timeline_sharp, color: Colors.blue.shade900),
                                                            const SizedBox(width: 10),
                                                            const Text(
                                                              'Progress',
                                                              style: TextStyle(fontSize: 20),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Container(
                                                    padding: const EdgeInsets.all(10),
                                                    margin: const EdgeInsets.symmetric(vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(
                                                        color: Colors.pink,
                                                        width: 3,
                                                      ),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Icon(Icons.whatshot, color: Colors.pink),
                                                            const SizedBox(width: 10),
                                                            const Text(
                                                              'Obstacle',
                                                              style: TextStyle(fontSize: 20),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Container(
                                                    padding: const EdgeInsets.all(10),
                                                    margin: const EdgeInsets.symmetric(vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(
                                                        color: Colors.black54,
                                                        width: 3,
                                                      ),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Icon(Icons.workspace_premium_sharp, color: Colors.black54),
                                                            const SizedBox(width: 10),
                                                            const Text(
                                                              'Rank',
                                                              style: TextStyle(fontSize: 20),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(10),
                                                    margin: const EdgeInsets.symmetric(vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(
                                                        color: Colors.blue.shade900,
                                                        width: 3,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      '${challenge['adjustedDaysPassed']} / ${challenge['finalDuration']} Days',
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 7),
                                                  Container(
                                                    padding: const EdgeInsets.all(10),
                                                    margin: const EdgeInsets.symmetric(vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(
                                                        color: Colors.pink,
                                                        width: 3,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      challenge['obstacle'],
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 7),
                                                  Container(
                                                    padding: const EdgeInsets.all(10),
                                                    margin: const EdgeInsets.symmetric(vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(
                                                        color: challenges[index]['rankColor'],
                                                        width: 3,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        challenges[index]['rankIcon'],
                                                        const SizedBox(width: 10),
                                                        Text(
                                                          challenges[index]['currentRank'],
                                                          style: const TextStyle(
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ]
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                          // Neue Spalte für die Buttons
                                          Column(
                                            children: [
                                                Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(10),
                                                    margin: const EdgeInsets.symmetric(vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const Text(
                                                              'Successful Days:',
                                                              style: TextStyle(fontSize: 20),
                                                            ),
                                                            const SizedBox(width: 10),
                                                            Text(
                                                              challenge['successfulDays'].toString(),
                                                              style: TextStyle(fontSize: 20),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 15),
                                                  Container(
                                                    padding: const EdgeInsets.all(10),
                                                    margin: const EdgeInsets.symmetric(vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const Text(
                                                              'Failed Days:',
                                                              style: TextStyle(fontSize: 20),
                                                            ),
                                                            const SizedBox(width: 10),
                                                            Text(
                                                              challenge['failedDays'].toString(),
                                                              style: TextStyle(fontSize: 20),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 15),
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                margin: const EdgeInsets.symmetric(vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: Colors.blueGrey[50],
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  '${challenge['description']}',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                'Created at: ${challenge['createdAt']}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.white,
                                                    size: 25,
                                                ),
                                                onPressed: () {
                                                  _deleteChallenge(challenge['id']);
                                                  _updateChallenges();
                                                  _fetchChallenges(currentDate);
                                                  setState(() {
                                                    _challengesFuture = _fetchChallenges(DateTime.now());

                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
