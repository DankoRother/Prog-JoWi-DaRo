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

      final DateTime createdAtDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
      final int daysPassed = currentDate.difference(createdAtDate).inDays;


      challenges.add({
        'id': doc.id, // Document ID zur Identifikation der Challenge
        'title': title,
        'description': description,
        'finalDuration': finalDuration,
        'frequency': frequency,
        'obstacle': obstacle,
        'createdAt': createdAt,
        'daysPassed': daysPassed, // Verstrichene Tage hinzufügen
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
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (BuildContext context, _, __) => EditChallenge(
                            //challengeId: challenge['id'], // Übergebe die Challenge-ID, wenn nötig
                          ),
                        ),
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      width: 300,
                      height: 280,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.pink, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.black54,
                          width: 3,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 15.0, right: 15.0),
                            child: Column(
                              children: [
                                Text(
                                  challenge['title'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
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
                                                    color: Colors.black54,
                                                    width: 3,
                                                  ),
                                                ),
                                                child: Text(
                                                  'first Place', // TODO: Logik für Rang fehlt
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 10,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.black54),
                              onPressed: () {
                                _deleteChallenge(challenge['id']);
                                setState(() {});
                              },
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
