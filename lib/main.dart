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
      title: 'Etwas Familienfreundliches',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        scaffoldBackgroundColor: Colors.blueGrey[400],
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

double screenHeight = 1440.0; //Standardwert, damit bei fehlender Initialisierung nicht nichts geht
double screenWidth = 3168.0;  //Standardwert, damit bei fehlender Initialisierung nicht nichts geht
double screenWidthAndHeight = screenWidth+screenHeight;
late TextStyle standardText;  //Standard TextStyle: Wenn nötig überschreibbar mit "standardText.copyWith(zu-überschreibende-Daten)
class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenHeight = MediaQuery.of(context).size.height;  //Setzen der Screenhöhe
    screenWidth = MediaQuery.of(context).size.width;    //Setzen der Screenbreite
    screenWidthAndHeight = screenWidth+screenHeight;
    standardText = TextStyle(                           //TODO: FontStyle der zur Anwendung passt entwickeln
      color: Colors.white,
      fontSize: screenHeight * 0.02,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5,
    );
  }
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
              width: screenWidth * 0.75,  // Feste Breite
              margin: EdgeInsets.only(top: screenHeight * 0.04),  // Abstand von oben
              padding: EdgeInsets.all(screenWidth * 0.02),  // Innerer Abstand
              decoration: BoxDecoration(
                color: Colors.indigoAccent,  // Hintergrundfarbe des Containers
                borderRadius: BorderRadius.circular(screenWidth * 0.4*0.08),  // Abrundung der Ecken
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,  // Minimiert die Größe der Spalte
                children: [
                  Text(
                    'Your Challenges',
                    style: standardText.copyWith(fontWeight: FontWeight.bold, fontSize: screenHeight*0.03),  // Textstil Überschrift
                    textAlign: TextAlign.center,  // Textzentrierung
                  ),
                  SizedBox(height: screenHeight * 0.02),  // Abstand zwischen Text und erstem Textfeld
                  TextField(
                    decoration: InputDecoration(
                      hintStyle: standardText.copyWith(fontSize: screenWidth*0.04, color: Colors.black),
                      hintText: 'Chöhe: $screenHeight breite: $screenWidth', //Anzeige der Maße zum entwickeln TODO: Entfernen vor finalem Produkt
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(vertical: screenWidth*0.01, horizontal: screenWidth*0.02),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),  // Abstand zwischen den Textfeldern
                  TextField(
                    decoration: InputDecoration(
                      hintStyle: standardText.copyWith(fontSize: screenWidth*0.04, color: Colors.black),
                      hintText: 'Challenge 2',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(vertical: screenWidth*0.01, horizontal: screenWidth*0.02),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),  // Abstand zwischen den Textfeldern
                  TextField(
                    decoration: InputDecoration(
                      hintStyle: standardText.copyWith(fontSize: screenWidth*0.04, color: Colors.black),
                      hintText: 'Challenge 3',
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(vertical: screenWidth*0.01, horizontal: screenWidth*0.02),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),  // Abstand zwischen dem letzten Textfeld und dem Button
                  ElevatedButton.icon(onPressed: () {
                    print('Button gedrückt');
                  },
                    icon: Icon(Icons.favorite_border),
                    label: Text('Like',style: standardText.copyWith(fontWeight: FontWeight.bold, fontSize: screenHeight * 0.03)),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blueGrey,   // Textfarbe des Buttons
                      padding: EdgeInsets.only(right: screenWidth * 0.025, left: screenWidth*0.025, top: screenHeight * 0.005, bottom: screenHeight * 0.005), // Innenabstand des Buttons
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
            top: screenWidth * 0.008,  // Abstand von oben (inklusive Statusleiste)
            left: screenWidth * 0.008,  // Abstand von links
            child: IconButton(
              icon: Icon(Icons.settings),
              color: Colors.white,  // Farbe des Icons
              iconSize: screenWidthAndHeight*0.025,  // Größe des Icons
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
              width: screenWidth * 0.75,  // Feste Breite
              height: screenHeight *0.6,// Feste Breite
              margin: EdgeInsets.only(top: screenHeight*0.05),  // Abstand von oben
              padding: EdgeInsets.all(screenWidthAndHeight*0.001),  // Innerer Abstand
              decoration: BoxDecoration(
                color: Colors.indigoAccent[300],  // Hintergrundfarbe des Containers
                borderRadius: BorderRadius.circular(5),  // Abrundung der Ecken
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,  // Minimiert die Größe der Spalte
                children: [
                  Text(
                    'Create your Challenge',
                    style: standardText.copyWith(fontSize: screenHeight * 0.035, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,  // Textzentrierung
                  ),
                  //Icon(Icons.draw, color: Colors.white),
                  SizedBox(height: screenHeight*0.008),
                  Container(
                    height: screenHeight * 0.07,
                    alignment: Alignment.topCenter,
                    child: TextFormField(
                      style: standardText.copyWith(
                          color: Colors.black,
                          fontSize: screenHeight * 0.035
                      ),
                      decoration: InputDecoration(
                        prefixText: 'Name: ',
                        prefixStyle: standardText.copyWith(
                          color: Colors.white,
                          fontSize: screenHeight * 0.02
                        ),
                        suffixIcon: Icon(
                            Icons.draw_outlined,
                            color: Colors.white,
                            size: screenWidth * 0.012
                        ),
                        hintText: '(Give your challenge a fancy name)',
                        hintStyle: standardText.copyWith(
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                          fontSize: screenHeight * 0.02,
                        ),
                        errorText: '* Default value!',
                        errorStyle: TextStyle(
                          color: Colors.red[600],
                          fontSize: screenHeight * 0.007,
                          fontWeight: FontWeight.bold,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.012),
                            borderSide: BorderSide(color: Colors.black54)
                        ),
                        fillColor: Colors.pink[700],
                        filled: true,
                      ),
                    ),
                  ),
                  Container(
                    height: screenHeight * 0.105,
                    child: TextFormField(
                      style: standardText.copyWith(color: Colors.white),
                      decoration: InputDecoration(
                        prefixText: 'What: ',
                        prefixStyle: standardText.copyWith(
                          color: Colors.white,
                          fontSize: screenHeight * 0.015,
                        ),
                        suffixIcon: Icon(
                            Icons.draw_outlined,
                            color: Colors.white,
                            size: screenWidth * 0.012
                        ),
                        hintText: '(On what to compete? Tell us :))',
                        hintStyle: standardText.copyWith(
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                          fontSize: screenHeight * 0.015,
                        ),
                        errorText: '* Default value!',
                        errorStyle: TextStyle(
                          color: Colors.red[600],
                          fontSize: screenHeight * 0.007,
                          fontWeight: FontWeight.bold,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.012),
                            borderSide: BorderSide(color: Colors.black54)
                        ),
                        fillColor: Colors.pink[700],
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.025,
                            horizontal: screenWidth * 0.009
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.007),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Time'),
                          Text('Intensity'),
                          Text('Obstacle'),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Time'),
                          Text('Intensity'),
                          Text('Obstacle'),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 20,),
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
              iconSize: 30,  // Größe des Icons
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
              iconSize: 30,  // Größe des Icons
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
