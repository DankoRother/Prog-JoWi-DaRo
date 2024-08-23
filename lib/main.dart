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
        page = Placeholder();
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
        selectedItemColor: Colors.pink[700],
        unselectedItemColor: Colors.blueGrey,
        backgroundColor: Colors.black87,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(color: Colors.grey),

        selectedIconTheme: const IconThemeData(
          size: 30,
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

class CurrentChallenges extends StatefulWidget {
  @override
  _CurrentChallengesState createState() => _CurrentChallengesState();
}

class _CurrentChallengesState extends State<CurrentChallenges> {
  int _currentStep = 0;
  int days = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              IconButton(
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
              SizedBox(width: 8),
              Container(
                alignment: Alignment.center,
                child: Text(
                  'Your current Challenges',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
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
        ),
        body: ListView(
          padding: EdgeInsets.all(16.0), // Abstand am Rand der Liste
          children: List.generate(10, (index) {
            return Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(vertical: 10.0), // Abstand zwischen den Containern
              width: 300,
              height: 400,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Name der Challenge $index'),
                  Text('Obstacle'),
                  Text('Days left'),
                  Text('Rank')
                ],
              ),
            );
          }),
        ),
    );
  }
}



class CreateChallenge extends StatefulWidget {
  @override
  _CreateChallengeState createState() => _CreateChallengeState();
}

class _CreateChallengeState extends State<CreateChallenge> {
  int _currentStep = 0;
  int days = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
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
            SizedBox(width: 8),
            Container(
              alignment: Alignment.center,
              child: Text(
                'Create your Challenge',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
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
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() {
              _currentStep++;
            });
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep--;
            });
          }
        },
        steps: [
          Step(
            title: Text(
              'Start',
              style: TextStyle(
                color: _currentStep == 0 ? Colors.indigoAccent : Colors.black,
                fontWeight: _currentStep == 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            content: Container(
              height: 400,
              child: Column(
                children: [
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
                ],
              ),
            )
          ),
          Step(
            title: Text(
              'Commit',
              style: TextStyle(
                color: _currentStep == 1 ? Colors.indigoAccent : Colors.black,
                fontWeight: _currentStep == 1 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            content: Container(
              height: 400,
              child: Column(
                children: [
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
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.access_time, color: Colors.black54), // Beispiel-Icon für "Time"
                                    SizedBox(width: 10), // Abstand zwischen Icon und Text
                                    Text(
                                      'Time',
                                      style: TextStyle(fontSize: 20), // Textstil
                                    ),
                                  ],
                                ),
                                Text(
                                    '(Duration?)',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                    )),
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
                                color: Colors.pink,
                                width: 3,
                              ),// Abrundung der Ecken
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.whatshot, color: Colors.pink), // Beispiel-Icon für "Intensity"
                                    SizedBox(width: 10), // Abstand zwischen Icon und Text
                                    Text(
                                      'Intensity',
                                      style: TextStyle(fontSize: 20), // Textstil
                                    ),
                                  ],
                                ),
                                Text(
                                    '(How often?)',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                    )
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
                                color: Colors.indigoAccent,
                                width: 3,
                              ),// Abrundung der Ecken
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.sports_kabaddi, color: Colors.indigoAccent), // Beispiel-Icon für "Obstacle"
                                    SizedBox(width: 10), // Abstand zwischen Icon und Text
                                    Text(
                                      'Obstacle',
                                      style: TextStyle(fontSize: 20), // Textstil
                                    ),
                                  ],
                                ),
                                Text(
                                    '(Objective?)',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                    )
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
                                  width: 200,
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
                                          textAlign: TextAlign.center,
                                          decoration: null,// Zentriert den Text
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
                                      SizedBox(width: 15,),
                                      SizedBox(
                                        width: 80,
                                        child: DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                          items: <String>['D', 'W', 'M', 'Y'].map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (newValue) {
                                            // Handle the value change here
                                          },
                                          hint: Text('Unit'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
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
                                  width: 200,
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
                          SizedBox(height: 20),
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
                                  width: 200,
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
                ],
              ),
            )
          ),
          Step(
            title: Text(
              'Ready?',
              style: TextStyle(
                color: _currentStep == 2 ? Colors.indigoAccent : Colors.black,
                fontWeight: _currentStep == 2 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            content: Container(
              height: 400,
              child: Column(
                children: [
                  SizedBox(
                    width: 300,
                    height: 50,
                    child: ElevatedButton.icon(onPressed: () {
                      print('Freund hinzufügen');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddFriendToChallenge()),
                      );
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
                  SizedBox(height: 20),
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
                            backgroundColor: Colors.indigoAccent,   // Textfarbe des Buttons
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
            )
          ),
        ],
        type: StepperType.horizontal,
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: details.onStepCancel,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blueGrey, // Textfarbe
                  backgroundColor: Colors.white, // Hintergrundfarbe
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Innenabstand
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Abrundung der Ecken
                  ),
                ),
                child: Icon(
                  Icons.keyboard_double_arrow_left_sharp,
                  size: 25,
                ),
              ),
              SizedBox(width: 40), // Abstand zwischen den Buttons
              ElevatedButton(
                onPressed: details.onStepContinue,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blueGrey, // Textfarbe
                  backgroundColor: Colors.white, // Hintergrundfarbe
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Innenabstand
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Abrundung der Ecken
                  ),
                ),
                child: Icon(
                  Icons.keyboard_double_arrow_right_sharp,
                  size: 25,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AddFriendToChallenge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 8),
            Container(
              alignment: Alignment.center,
              child: Text(
                'Add your Friends',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey.shade400, Colors.pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Center(
        child: Text('Here you can add the friends you´d like to challenge.'),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 8),
            Container(
              alignment: Alignment.center,
              child: Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey.shade400, Colors.pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Center(
        child: Text('Hier kommen deine Einstellungen hin.'),
      ),
    );
  }
}


