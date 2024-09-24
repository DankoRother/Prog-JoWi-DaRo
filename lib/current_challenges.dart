import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';// Importiere Provider für AuthProvider

import 'settings.dart';
import 'edit_challenge.dart';
import 'authentication_provider.dart';// Importiere AuthProvider
import 'main.dart';
import 'date_notifier.dart';

class CurrentChallenges extends StatefulWidget {
  const CurrentChallenges({super.key});

  @override
  _CurrentChallengesState createState() => _CurrentChallengesState();
}

class _CurrentChallengesState extends State<CurrentChallenges> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore-Instanz
  //bool _isExpanded = false;

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

      final DateTime createdAtDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
      final int daysPassed = currentDate.difference(createdAtDate).inDays + 1;

      final double _successRate = daysPassed > 0 ? successfulDays / daysPassed : 0;

      String rank;
      Color rankColor;
      Icon rankIcon;

      if (_successRate >= 0.8) {
        rank = 'Gold';
        rankColor = Colors.amber; // Goldene Farbe
        rankIcon = Icon(Icons.star, color: rankColor, size: 30,); // Star-Icon
      } else if (_successRate >= 0.75) {
        rank = 'Silver';
        rankColor = Colors.grey.shade400; // Silberne Farbe
        rankIcon = Icon(Icons.star_half, color: rankColor, size: 28,); // Halber Stern
      } else if (_successRate >= 0.5) {
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
        'daysPassed': daysPassed, // Verstrichene Tage hinzufügen
        'currentRank': currentRank,
        'rankColor': rankColor, // Hinzufügen von Farbe
        'rankIcon': rankIcon,   // Hinzufügen von Icon
      });
    }
    return challenges;
  }

  Future<void> _deleteChallenge(String challengeId) async {
    try {
      await _firestore.collection('challenge').doc(challengeId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Challenge erfolgreich gelöscht')),
      );
      _updateChallenges();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Löschen der Challenge: $e')),
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
      body: isLoggedIn ? _buildChallengesPage() : _buildLoginPromptPage(),
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
                  return InkWell(
                    onTap: () {
                      /*Navigator.push(
                        context,
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (BuildContext context, _, __) => EditChallenge(
                            challengeId: challenge['id'], // Richtiges Komma statt Strichpunkt
                            challengeProgess: challenge['daysPassed'], // Übergebe die Challenge-ID, wenn nötig
                          ),
                        ),
                      );*/
                    },
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade600,
                        /*gradient: const LinearGradient(
                          colors: [Colors.pink, Colors.blueGrey],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),*/
                        border: Border.all(
                          color: challenges[index]['rankColor'],
                          width: 3, // Dicke der Umrandung
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 15.0, right: 15.0),
                            child: Column(
                              children: [
                                /*Text(
                                  challenge['title'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),
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
                                                  color: Colors.blueGrey[50],
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
                                                  color: Colors.blueGrey[50],
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: Colors.pink,
                                                    width: 3,
                                                  ),
                                                ),
                                                child: Text(
                                                  'Obstacle',
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                margin: const EdgeInsets.symmetric(vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: Colors.blueGrey[50],
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: Colors.black54,
                                                    width: 3,
                                                  ),
                                                ),
                                                child: Text(
                                                  'Rank', // Hier sollte die Rang-Logik implementiert werden
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                  ),
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
                                                  color: Colors.blueGrey[50],
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: Colors.blue.shade900,
                                                    width: 3,
                                                  ),
                                                ),
                                                child: Text(
                                                  '${challenge['daysPassed']} / ${challenge['finalDuration']}',
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
                                                  color: Colors.blueGrey[50],
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
                                                  color: Colors.blueGrey[50],
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
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),*/
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
                                      ElevatedButton.icon(onPressed: () {
                                        Navigator.of(context).push(
                                          PageRouteBuilder(
                                            opaque: false,
                                            pageBuilder: (BuildContext context, _, __) => EditChallenge(
                                              challengeId: challenge['id'], // Übergebe die Challenge-ID
                                              challengeProgess: challenge['daysPassed'], // Übergebe den Fortschritt
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
                                  /*initiallyExpanded: _isExpanded, // Setzt den initialen Zustand
                                  onExpansionChanged: (bool expanded) {
                                    setState(() {
                                      _isExpanded = expanded; // Speichert, ob es expanded ist
                                    });
                                  },*/
                                  children: [
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
                                                      color: Colors.blueGrey[50],
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
                                                      color: Colors.blueGrey[50],
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(
                                                        color: Colors.pink,
                                                        width: 3,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'Obstacle',
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Container(
                                                    padding: const EdgeInsets.all(10),
                                                    margin: const EdgeInsets.symmetric(vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blueGrey[50],
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(
                                                        color: Colors.black54,
                                                        width: 3,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'Rank', // Hier sollte die Rang-Logik implementiert werden
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                      ),
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
                                                      color: Colors.blueGrey[50],
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(
                                                        color: Colors.blue.shade900,
                                                        width: 3,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      '${challenge['daysPassed']} days/ ${challenge['finalDuration']} days',
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
                                                      color: Colors.blueGrey[50],
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
                                                      color: Colors.blueGrey[50],
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
                                          const SizedBox(height: 20),
                                          // Neue Spalte für die Buttons
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                challenge['description'],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                ),
                                              ),
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

  // Widget für nicht eingeloggte Benutzer
  Widget _buildLoginPromptPage() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Please log in to see your Challenges! \n Go to Accountpage to log in',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
