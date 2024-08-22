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
  int days = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Der Container mit dem Inhalt der Seite
          Align(
            alignment: Alignment.topCenter, // Horizontale Zentrierung, oben angeordnet
            child: Container(
              width: screenWidth * 0.75, // Feste Breite
              //height: screenHeight * 0.6, // Feste Höhe
              margin: EdgeInsets.only(top: screenHeight * 0.05), // Abstand von oben
              padding: EdgeInsets.all(screenWidthAndHeight * 0.001), // Innerer Abstand
              decoration: BoxDecoration(
                color: Colors.indigoAccent[300], // Hintergrundfarbe des Containers
                borderRadius: BorderRadius.circular(5), // Abrundung der Ecken
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Minimiert die Größe der Spalte
                children: [
                  Text(
                    'Create your Challenge',
                    style: TextStyle(
                      fontSize: screenHeight * 0.035,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center, // Textzentrierung
                  ),
                  SizedBox(height: screenHeight * 0.008),
                  //Icon(Icons.draw, color: Colors.white),
                  SizedBox(height: screenHeight*0.012),
                  Container(
                    height: screenHeight * 0.05,
                    child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          return Stack(
                            children: [
                            TextField(
                            textAlignVertical: TextAlignVertical.center,
                            style: standardText.copyWith(
                              color: Colors.black,
                              fontSize: constraints.maxHeight * 0.33,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(
                                // Adjust bottom padding to make space for error text
                                bottom: constraints.maxHeight * 0.4,
                                // You might need to fine-tune this value
                                left: constraints.maxWidth * 0.02,
                              ),
                              prefix: Text('Name: '),
                              prefixStyle: standardText.copyWith(
                                color: Colors.white,
                                fontSize: constraints.maxHeight * 0.4,
                              ),
                              suffixIcon: Icon(
                                Icons.draw_outlined,
                                color: Colors.white,
                                size: constraints.maxHeight * 0.4,
                              ),
                              hintText: 'Give your challenge a fancy name!',
                              hintStyle: standardText.copyWith(
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                                fontSize: constraints.maxHeight * 0.4,
                              ),
                              // Remove errorText from InputDecoration
                              border: OutlineInputBorder(),
                              // You can add border styling if needed
                              fillColor: Colors.pink[700],
                              filled: true,
                            ),
                          ),
                          Positioned(
                            bottom: constraints.maxHeight * -0.13, // Position the error text at the bottom
                            left: constraints.maxWidth*0.5, // Align it in the center
                            child: Text(
                              '* Default value!',
                              style: standardText.copyWith(
                                color: Colors.blue,
                                fontSize: constraints.maxHeight * 0.2,
                              ),
                            ),
                          ),
                            ],
                          );
                        }
                    ),
                  ),
                  Container(
                    height: screenHeight * 0.105,
                    child: TextFormField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        prefixText: 'What: ',
                        prefixStyle: TextStyle(
                          color: Colors.white,
                          fontSize: screenHeight * 0.015,
                        ),
                        suffixIcon: Icon(
                          Icons.draw_outlined,
                          color: Colors.white,
                          size: screenWidth * 0.012,
                        ),
                        hintText: '(On what to compete? Tell us :))',
                        hintStyle: TextStyle(
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
                          borderSide: BorderSide(color: Colors.black54),
                        ),
                        fillColor: Colors.pink[700],
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.025,
                          horizontal: screenWidth * 0.009,
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
                          Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50], // Hintergrundfarbe
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.black54,
                                width: 3,
                              ),// Abrundung der Ecken
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time, color: Colors.black54), // Beispiel-Icon für "Time"
                                SizedBox(width: 10), // Abstand zwischen Icon und Text
                                Text(
                                  'Time',
                                  style: TextStyle(fontSize: 20), // Textstil
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50], // Hintergrundfarbe
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.red,
                                width: 3,
                              ),// Abrundung der Ecken
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.whatshot, color: Colors.red), // Beispiel-Icon für "Intensity"
                                SizedBox(width: 10), // Abstand zwischen Icon und Text
                                Text(
                                  'Intensity',
                                  style: TextStyle(fontSize: 20), // Textstil
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50], // Hintergrundfarbe
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.orange,
                                width: 3,
                              ),// Abrundung der Ecken
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.sports_kabaddi, color: Colors.orange), // Beispiel-Icon für "Obstacle"
                                SizedBox(width: 10), // Abstand zwischen Icon und Text
                                Text(
                                  'Obstacle',
                                  style: TextStyle(fontSize: 20), // Textstil
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Erstes Textfeld mit zugehörigem Input-Feld
                          Container(
                            padding: EdgeInsets.all(5),
                            margin: EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50], // Hintergrundfarbe
                              borderRadius: BorderRadius.circular(10), // Abrundung der Ecken
                            ),
                            child: Column(
                              //crossAxisAlignment: CrossAxisAlignment.start, // Links ausrichten
                              children: [
                                SizedBox(
                                  width: 210,
                                  child: Row(
                                    children: [
                                      // Minus-Button
                                      IconButton(
                                        icon: Icon(Icons.remove),
                                        onPressed: () {
                                          setState(() {
                                            if (days > 0) days--;  // Verringert die Anzahl der Tage
                                          });
                                        },
                                      ),

                                      // Textfeld, das den aktuellen Wert anzeigt
                                      Expanded(
                                        child: TextField(
                                          controller: TextEditingController(text: days.toString()),
                                          readOnly: true,  // Verhindert manuelle Eingabe
                                          textAlign: TextAlign.center,  // Zentriert den Text
                                        ),
                                      ),

                                      // Plus-Button
                                      IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: () {
                                          setState(() {
                                            days++;  // Erhöht die Anzahl der Tage
                                          });
                                        },
                                      ),
                                      SizedBox(
                                        width: 110,
                                        child: DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                          items: <String>['days', 'weeks', 'months', 'years'].map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (newValue) {
                                            // Handle the value change here
                                          },
                                          hint: Text(' '),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 7),
                          // Zweites Textfeld mit Dropdown-Menü
                          Container(
                            padding: EdgeInsets.all(5),
                            margin: EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 210,
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                    items: <String>['daily', 'weekly', 'biweekly'].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      // Handle the value change here
                                    },
                                    hint: Text('Select intensity'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 7),
                          // Drittes Textfeld mit zugehörigem Input-Feld
                          Container(
                            padding: EdgeInsets.all(5),
                            margin: EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 210,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Enter obstacle',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: 300,
                    height: 50,
                    child: ElevatedButton.icon(onPressed: () {
                      print('Freund hinzufügen');
                    },
                      icon: Icon(
                          Icons.add_circle_outline_sharp,
                          size: 25,
                      ),
                      label: Text(
                          'Add Friends',
                          style: TextStyle(
                            fontSize: 15,
                          )
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.pink,   // Textfarbe des Buttons
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Innenabstand des Buttons
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Abrundung der Ecken
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          'Is everything correct?',
                          style: TextStyle(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                      ),
                      SizedBox(width: 20,),
                      SizedBox(
                        width: 150,
                        height: 40,
                        child: ElevatedButton.icon(onPressed: () {
                          print('Erstelle Challenge');
                        },
                          label: Text(
                              'Create',
                              style: TextStyle(
                                fontSize: 20,
                              )
                          ),
                          icon: Icon(
                            Icons.done_outline_sharp,
                            size: 20,
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green,   // Textfarbe des Buttons
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Innenabstand des Buttons
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25), // Abrundung der Ecken
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Einstellungs-Icon oben links
          Positioned(
            top: 15, // Abstand von oben (inklusive Statusleiste)
            left: 15, // Abstand von links
            child: IconButton(
              icon: Icon(Icons.settings),
              color: Colors.white, // Farbe des Icons
              iconSize: 30, // Größe des Icons
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
