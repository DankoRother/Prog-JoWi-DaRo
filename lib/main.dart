import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fick deine Mutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        scaffoldBackgroundColor: Colors.blueGrey,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = YourChallenges();
        break;
      case 1:
        page = FriendsList();
        break;
      case 2:
        page = CreateChallenge();
        break;
      case 3:
        page = CurrentChallenges();
        break;
      case 4:
        page = Placeholder();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: page,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.message_rounded),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'New',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.speed_sharp),
            label: 'Challenges',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Konto',
          ),
        ],
        selectedItemColor: Colors.indigoAccent,
        unselectedItemColor: Colors.blueGrey,
        backgroundColor: Colors.black87,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(color: Colors.grey),

        selectedIconTheme: const IconThemeData(
          size: 35,
        ),
        unselectedIconTheme: const IconThemeData(
          size: 25,
        ),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class YourChallenges extends StatefulWidget {
  @override
  _YourChallengesState createState() => _YourChallengesState();
}

class _YourChallengesState extends State<YourChallenges> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Der Container mit dem Inhalt der Seite
          Align(
            alignment: Alignment.topCenter,  // Horizontale Zentrierung, oben angeordnet
            child: Container(
              width: 375,  // Feste Breite
              margin: EdgeInsets.only(top: 60),  // Abstand von oben
              padding: EdgeInsets.all(15),  // Innerer Abstand
              decoration: BoxDecoration(
                color: Colors.indigoAccent,  // Hintergrundfarbe des Containers
                borderRadius: BorderRadius.circular(5),  // Abrundung der Ecken
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,  // Minimiert die Größe der Spalte
                children: [
                  Text(
                    'Your Challenges',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),  // Textstil
                    textAlign: TextAlign.center,  // Textzentrierung
                  ),
                  SizedBox(height: 20),  // Abstand zwischen Text und erstem Textfeld
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Challenge 1',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 10),  // Abstand zwischen den Textfeldern
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Challenge 2',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 10),  // Abstand zwischen den Textfeldern
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Challenge 3',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 20),  // Abstand zwischen dem letzten Textfeld und dem Button
                  ElevatedButton(
                    onPressed: () {
                      // Hier kannst du die Funktion für den Button hinzufügen
                    },
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
          ),

          // Einstellungs-Icon oben links
          Positioned(
            top: 15,  // Abstand von oben (inklusive Statusleiste)
            left: 15,  // Abstand von links
            child: IconButton(
              icon: Icon(Icons.settings),
              color: Colors.white,  // Farbe des Icons
              iconSize: 25,  // Größe des Icons
              onPressed: () {
                // Hier kommt die Navigation zur Einstellungsseite
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CreateChallenge extends StatefulWidget {
  @override
  _CreateChallengeState createState() => _CreateChallengeState();
}

class _CreateChallengeState extends State<CreateChallenge> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Der Container mit dem Inhalt der Seite
          Align(
            alignment: Alignment.topCenter,  // Horizontale Zentrierung, oben angeordnet
            child: Container(
              width: 375,  // Feste Breite
              margin: EdgeInsets.only(top: 60),  // Abstand von oben
              padding: EdgeInsets.all(15),  // Innerer Abstand
              decoration: BoxDecoration(
                color: Colors.indigoAccent,  // Hintergrundfarbe des Containers
                borderRadius: BorderRadius.circular(5),  // Abrundung der Ecken
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,  // Minimiert die Größe der Spalte
                children: [
                  Text(
                    'Your Challenges',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),  // Textstil
                    textAlign: TextAlign.center,  // Textzentrierung
                  ),
                  SizedBox(height: 20),  // Abstand zwischen Text und erstem Textfeld
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Challenge 1',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 10),  // Abstand zwischen den Textfeldern
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Challenge 2',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 10),  // Abstand zwischen den Textfeldern
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Challenge 3',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 20),  // Abstand zwischen dem letzten Textfeld und dem Button
                  ElevatedButton(
                    onPressed: () {
                      // Hier kannst du die Funktion für den Button hinzufügen
                    },
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
          ),

          // Einstellungs-Icon oben links
          Positioned(
            top: 15,  // Abstand von oben (inklusive Statusleiste)
            left: 15,  // Abstand von links
            child: IconButton(
              icon: Icon(Icons.settings),
              color: Colors.white,  // Farbe des Icons
              iconSize: 25,  // Größe des Icons
              onPressed: () {
                // Hier kommt die Navigation zur Einstellungsseite
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CurrentChallenges extends StatefulWidget {
  @override
  _CurrentChallengesState createState() => _CurrentChallengesState();
}

class _CurrentChallengesState extends State<CurrentChallenges> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Der Container mit dem Inhalt der Seite
          Align(
            alignment: Alignment.topCenter,  // Horizontale Zentrierung, oben angeordnet
            child: Container(
              width: 375,  // Feste Breite
              margin: EdgeInsets.only(top: 60),  // Abstand von oben
              padding: EdgeInsets.all(15),  // Innerer Abstand
              decoration: BoxDecoration(
                color: Colors.indigoAccent,  // Hintergrundfarbe des Containers
                borderRadius: BorderRadius.circular(5),  // Abrundung der Ecken
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,  // Minimiert die Größe der Spalte
                children: [
                  Text(
                    'Your Challenges',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),  // Textstil
                    textAlign: TextAlign.center,  // Textzentrierung
                  ),
                  SizedBox(height: 20),  // Abstand zwischen Text und erstem Textfeld
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Challenge 1',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 10),  // Abstand zwischen den Textfeldern
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Challenge 2',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 10),  // Abstand zwischen den Textfeldern
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Challenge 3',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 20),  // Abstand zwischen dem letzten Textfeld und dem Button
                  ElevatedButton(
                    onPressed: () {
                      // Hier kannst du die Funktion für den Button hinzufügen
                    },
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
          ),

          // Einstellungs-Icon oben links
          Positioned(
            top: 15,  // Abstand von oben (inklusive Statusleiste)
            left: 15,  // Abstand von links
            child: IconButton(
              icon: Icon(Icons.settings),
              color: Colors.white,  // Farbe des Icons
              iconSize: 25,  // Größe des Icons
              onPressed: () {
                // Hier kommt die Navigation zur Einstellungsseite
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FriendsList extends StatefulWidget {
  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Der Container mit dem Inhalt der Seite
          Align(
            alignment: Alignment.topCenter,  // Horizontale Zentrierung, oben angeordnet
            child: Container(
              width: 375,  // Feste Breite
              margin: EdgeInsets.only(top: 60),  // Abstand von oben
              padding: EdgeInsets.all(15),  // Innerer Abstand
              decoration: BoxDecoration(
                color: Colors.indigoAccent,  // Hintergrundfarbe des Containers
                borderRadius: BorderRadius.circular(5),  // Abrundung der Ecken
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,  // Minimiert die Größe der Spalte
                children: [
                  Text(
                    'Your Challenges',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),  // Textstil
                    textAlign: TextAlign.center,  // Textzentrierung
                  ),
                  SizedBox(height: 20),  // Abstand zwischen Text und erstem Textfeld
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Challenge 1',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 10),  // Abstand zwischen den Textfeldern
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Challenge 2',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 10),  // Abstand zwischen den Textfeldern
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Challenge 3',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 20),  // Abstand zwischen dem letzten Textfeld und dem Button
                  ElevatedButton.icon(onPressed: () {
                    print('Button gedrückt');
                  },
                    icon: Icon(Icons.favorite_border),
                    label: Text('Like'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blueGrey,   // Textfarbe des Buttons
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Innenabstand des Buttons
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Abrundung der Ecken
                      ),
                    ),

                  )
                ],
              ),
            ),
          ),

          // Einstellungs-Icon oben links
          Positioned(
            top: 15,  // Abstand von oben (inklusive Statusleiste)
            left: 15,  // Abstand von links
            child: IconButton(
              icon: Icon(Icons.settings),
              color: Colors.white,  // Farbe des Icons
              iconSize: 25,  // Größe des Icons
              onPressed: () {
                // Hier kommt die Navigation zur Einstellungsseite
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Text('Hier kommen deine Einstellungen hin.'),
      ),
    );
  }
}
