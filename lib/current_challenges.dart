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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLessOrEqualFilter = true;

  @override
  void initState() {
    super.initState();
  }

  Stream<List<Map<String, dynamic>>> _getChallengesStream(DateTime currentDate) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null || user.challenges.isEmpty) {
      return Stream.value([]); // Return empty stream if no challenges
    }

    return _firestore
        .collection('challenge')
        .where(FieldPath.documentId, whereIn: user.challenges.isNotEmpty ? user.challenges : ['dummy']) // Handle empty whereIn case
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((challengesSnapshot) {
      List<Map<String, dynamic>> challenges = [];

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

        final DateTime createdAtDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
        final int daysPassed = currentDate.difference(createdAtDate).inDays + 1;
        final int adjustedDaysPassed = daysPassed > finalDuration ? finalDuration : daysPassed;

        final double _successRate = adjustedDaysPassed > 0 ? successfulDays / adjustedDaysPassed : 0;

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
    });
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
      // Remove the challenge ID from the user's challenge list
      await _firestore.collection('users').doc(user.uid).update({
        'challenges': FieldValue.arrayRemove([challengeId]),
      });

      // Update the challenge to remove the user from the challenge's user list
      await _firestore.collection('challenge').doc(challengeId).update({
        'users': FieldValue.arrayRemove([user.uid]),
      });

      // Fetch updated user data and update AuthProvider
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      List<String> updatedChallenges = List<String>.from(userDoc.data()?['challenges'] ?? []);
      authProvider.updateUserChallenges(updatedChallenges);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Challenge removed from your list successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove challenge: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isLoggedIn = authProvider.isLoggedIn;
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
                  Switch(
                    value: isLessOrEqualFilter,
                    onChanged: (bool newValue) {
                      setState(() {
                        isLessOrEqualFilter = newValue;
                      });
                    },
                    activeColor: Colors.pink,
                    inactiveThumbColor: Colors.blueGrey.shade400,
                    inactiveTrackColor: Colors.blueGrey.shade200,
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
      body: isLoggedIn ? _buildChallengesPage() : LogInPrompt(),
    );
  });
  }
  Widget _buildChallengesPage() {
    return ValueListenableBuilder<DateTime>(
      valueListenable: simulatedDate,
      builder: (context, simulatedDate, child) {
        final DateTime currentDate = DateTime(simulatedDate.year, simulatedDate.month, simulatedDate.day);
        final authProvider = Provider.of<AuthProvider>(context);

        if (authProvider.currentUser == null) {
          return const Center(child: Text('No user logged in'));
        }

        final userChallenges = authProvider.currentUser!.challenges;

        return StreamBuilder<List<Map<String, dynamic>>>(
          key: ValueKey(userChallenges), // Add this line
          stream: _getChallengesStream(currentDate),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error while fetching data: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No active Challenges found'));
            }

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
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: challenges.length,
                itemBuilder: (context, index) {
                  final challenge = challenges[index];
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
                              value: challenge['adjustedDaysPassed'] / challenge['finalDuration'],
                              backgroundColor: Colors.blueGrey.shade600,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              if (completedChallenge)
                                Column(
                                  children: [
                                    Text(
                                      '${challenges[index]['title']} completed at rank ${challenges[index]['currentRank']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 10),
                                    Icon(
                                      Icons.check_circle_outline_sharp,
                                      color: challenges[index]['rankColor'],
                                      size: 40,
                                    ),
                                  ],
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
                                    ElevatedButton.icon(
                                      onPressed: completedChallenge
                                          ? null
                                          : () {
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
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.pink,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 12.0,
                                        ),
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
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Your Challenge can be found in the archive once the duration is over (${challenge['finalDuration']} + 1 Day).',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
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
                                    },
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
