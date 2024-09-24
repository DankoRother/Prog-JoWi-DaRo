import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';// Importiere Provider für AuthProvider
import 'settings.dart';
import 'edit_challenge.dart';
import 'authentication_provider.dart';// Importiere AuthProvider
import 'main.dart';
import 'date_notifier.dart';
import 'logInPrompt.dart';
import 'appBar.dart';

class CurrentChallenges extends StatefulWidget {
  const CurrentChallenges({super.key});

  @override
  _CurrentChallengesState createState() => _CurrentChallengesState();
}

class _CurrentChallengesState extends State<CurrentChallenges> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore-Instanz

  late Future<List<Map<String, dynamic>>> _challengesFuture;

  @override
  void initState() {
    super.initState();
    _updateChallenges();
  }

  void _updateChallenges() {
    final currentDate = DateTime.now(); // Beispiel für aktuelles Datum
    _challengesFuture = _fetchChallenges(currentDate);
  }

  Future<List<Map<String, dynamic>>> _fetchChallenges(DateTime currentDate) async {
    final challengesSnapshot = await _firestore
        .collection('challenge')
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

      final DateTime createdAtDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
      final int daysPassed = currentDate.difference(createdAtDate).inDays; //TODO: macht das sinn mit +1 oder lieber challenge bei tag 0 anfangen lassen

      final int adjustedDaysPassed = daysPassed >= finalDuration ? finalDuration : daysPassed;

      final double _successRate = adjustedDaysPassed > 0 ? successfulDays / adjustedDaysPassed : 0;

      String rank;
      Color rankColor;
      Icon rankIcon;

      if (_successRate >= 0.8) {
        rank = 'Gold';
        rankColor = Colors.amber; // Goldene Farbe
        rankIcon = Icon(Icons.star, color: rankColor, size: 30,); // Star-Icon
      } else if (_successRate < 0.8 && _successRate >= 0.6) {
        rank = 'Silver';
        rankColor = Colors.grey.shade400; // Silberne Farbe
        rankIcon = Icon(Icons.star_half, color: rankColor, size: 28,); // Halber Stern
      } else if (_successRate < 0.6 && _successRate >= 0.4) {
        rank = 'Bronze';
        rankColor = Colors.brown; // Bronzefarbene Farbe
        rankIcon = Icon(Icons.emoji_events, color: rankColor, size: 26,); // Trophäen-Icon
      } else {
        rank = 'Participant';
        rankColor = Colors.black54; // Neutrale Farbe
        rankIcon = Icon(Icons.person, color: rankColor, size: 24,); // Benutzer-Icon
      }


      final currentRank = rank; //rank is not safed in database because in real life there´s no opportunity to manipulate the date and therefore no need to safe the rank in the database

      challenges.add({
        'id': doc.id, // Document ID zur Identifikation der Challenge
        'title': title,
        'description': description,
        'finalDuration': finalDuration,
        'frequency': frequency,
        'obstacle': obstacle,
        'createdAt': createdAt,
        'daysPassed': adjustedDaysPassed, // Verstrichene Tage hinzufügen
        'currentRank': currentRank,
        'rankColor': rankColor, // Hinzufügen von Farbe
        'rankIcon': rankIcon,   // Hinzufügen von Icon
        'successfulDays': successfulDays,
        'failedDays': failedDays,
      });
    }
    return challenges;
  }

  Future<void> _deleteChallenge(String challengeId) async {
    try {
      await _firestore.collection('challenge').doc(challengeId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Challenge deleted successfully')),
      );
      _updateChallenges();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failing to delete Challenge: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context); // AuthProvider abrufen
    //authProvider.checkLoginStatus();
    final isLoggedIn = authProvider.isLoggedIn; // Anmeldestatus abrufen

    bool canPop = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.center,
              child: Text(
                isLoggedIn ? 'Your current Challenges' : 'Current Challenges',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
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
              const SnackBar(
                backgroundColor: Colors.pink,
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
  }

  // Widget für eingeloggte Benutzer mit geladenen Challenges
  Widget _buildChallengesPage() {
    return ValueListenableBuilder<DateTime>(
      valueListenable: simulatedDate, // Beobachte das manipulierte Datum
      builder: (context, simulatedDate, child) {
        final DateTime currentDate = DateTime(simulatedDate.year, simulatedDate.month, simulatedDate.day);

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchChallenges(currentDate), // Verwende die Methode ohne Parameter
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Fehler beim Laden der Daten: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Keine Herausforderungen gefunden'));
            }

            final challenges = snapshot.data!;

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
                  final completedChallenge = challenge['daysPassed'] >= challenge['finalDuration'];
                  return Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade600,
                        border: Border.all(
                          color: challenges[index]['rankColor'],
                          width: 3, // Dicke der Umrandung
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12), // Abrunden der Ecken
                              child: LinearProgressIndicator(
                                value: challenge['daysPassed'] / (challenge['finalDuration']), // Berechnung des Fortschritts
                                backgroundColor: Colors.blueGrey.shade600,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 15.0, right: 15.0),
                            child: Column(
                              children: [
                              if (completedChallenge) // Hinweistext für abgeschlossene Challenges
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
                                      ElevatedButton.icon(onPressed: completedChallenge ? null : () {
                                        Navigator.of(context).push(
                                          PageRouteBuilder(
                                            opaque: false,
                                            pageBuilder: (BuildContext context, _, __) => EditChallenge(
                                              challengeId: challenge['id'], // Übergebe die Challenge-ID
                                              challengeProgess: challenge['daysPassed'], // Übergebe den Fortschritt
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
                                          'Progress Day 0 marks already the first day of ${challenge['title']}, so you can directly start participating in your Challenge. '
                                          'Your final rank will be revealed at Challenge Day (duration: ${challenge['finalDuration']} Days) + 1. '
                                          '\n Challenge Day: ${challenge['daysPassed'] +1}',
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
                                                      '${challenge['daysPassed']} / ${challenge['finalDuration']} Days',
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
                                                        color: challenges[index]['rankColor'], // Verwende die Rank-Farbe
                                                        width: 3,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        challenges[index]['rankIcon'], // Verwende das Rank-Icon
                                                        const SizedBox(width: 10),
                                                        Text(
                                                          challenges[index]['currentRank'], // Rank-Text
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
                                              const SizedBox(height: 10), // Abstand zwischen den Buttons
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.white,
                                                    size: 25,
                                                ),
                                                onPressed: () {
                                                  _deleteChallenge(challenge['id']);
                                                  setState(() {});
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
