import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:flutter/src/material/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'authentication_provider.dart';
import 'current_challenges.dart';
import 'main.dart';
import 'challenge_created_confirmation.dart';
import 'addfriend_createchallenge.dart';
import 'logInPrompt.dart';
import 'appBar.dart';

class CreateChallenge extends StatefulWidget {
  const CreateChallenge({super.key});

  @override
  CreateChallengeState createState() => CreateChallengeState();
}

class CreateChallengeState extends State<CreateChallenge> {
  final _formKey = GlobalKey<FormState>();
  int currentStep = 0;
  int _duration = 7;
  String? _selectedUnit = 'D';
  String? _selectedFrequency = 'daily';
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  late TextEditingController _obstacle = TextEditingController();

  Future checkMissingValues() async {
    if (_obstacle.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.pink,
          content: Text('Do not forget to add an obstacle in your challenge'),
        ),
      );
      return false; // Rückgabewert anpassen
    }
    return true; // Rückgabewert anpassen
  }

  Future<void> _saveChallenge() async {
    String title = _title.text;
    String description = _description.text;
    String obstacle = _obstacle.text;
    String? frequency = _selectedFrequency;

    // Faktor basierend auf der ausgewählten Einheit
    int factor;
    switch (_selectedUnit) {
      case 'D':
        factor = 1; // Tägliche Einheit, keine Multiplikation nötig
        break;
      case 'W':
        factor = 7; // Wöchentliche Einheit (1 Woche = 7 Tage)
        break;
      case 'M':
        factor = 30; // Monatliche Einheit (1 Monat = 30 Tage)
        break;
      case 'Y':
        factor = 365; // Jährliche Einheit (1 Jahr = 365 Tage)
        break;
      default:
        factor = 1;
    }

    // Berechnung des Ergebnisses
    int finalDuration = _duration * factor;

    try {
      // Challenge in Firestore-Sammlung "challenge" speichern
      await FirebaseFirestore.instance.collection('challenge').add({
        'title': title,
        'description': description,
        'finalDuration': finalDuration,
        'frequency': frequency,
        'obstacle': obstacle,
        'createdAt': Timestamp.now(),
      });

      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (context, animation,
              secondaryAnimation) =>
              ChallengeCreatedConfirmation(
                data: _title.text,
                duration: const Duration(seconds: 5),
                onNavigate: (int selectedIndex) {
                  Navigator.of(context)
                      .pop(); // Schließt die Bestätigungsseite

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (
                          context) => const CurrentChallenges(),
                    ),
                  );
                },
              ),
        ),
      );

      Future.delayed(const Duration(seconds: 5), () {
        _title.clear();
        _description.clear();
        _obstacle.clear();
        setState(() {
          _duration = 7;
          _selectedUnit = 'D';
        });
      });

    } catch (e) {
      // Fehlerbehandlung
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Fehler beim Erstellen der Challenge: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    authProvider.checkLoginStatus();
    final isLoggedIn = authProvider.isLoggedIn;

    return Scaffold(
      appBar: buildAppBar(
        context: context,
        loggedInTitle: 'Create your new Challenge', // Titel wenn eingeloggt
        loggedOutTitle: 'Create new Challenge', // Titel wenn nicht eingeloggt
      ),
      body: isLoggedIn ? _buildChallengeForm() : LogInPrompt(),
    );
  }

  Widget _buildChallengeForm() {
    return Stepper(
      currentStep: currentStep,
      //onStepTapped: (step) => setState(() => _currentStep = step),
      //TODO: entscheiden ob bearbeitung direkt über stepperleiste notwendig sein soll
      onStepContinue: () {
        if (currentStep < 2) {
          setState(() {
            currentStep++;
          });
        }
      },
      onStepCancel: () {
        if (currentStep > 0) {
          setState(() {
            currentStep--;
          });
        }
      },
      steps: [
        Step(
          title: Text(
            'Start',
            style: TextStyle(
              color: currentStep == 0 ? Colors.blue[900] : Colors.black,
              fontWeight: currentStep == 0 ? FontWeight.bold : FontWeight
                  .normal,
            ),
          ),
          content: SizedBox(
            height: 400,
            child: Form(
              key: _formKey, // Verbinden des Formulars mit dem GlobalKey
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Überschrift für das erste TextFormField
                  Text(
                    'Name:',
                    style: TextStyle(
                      color: Colors.white,
                      // Sie können die Farbe nach Bedarf anpassen
                      fontSize: screenHeight * 0.03, // Überschrift Größe
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  // Abstand zwischen Überschrift und TextFormField
                  // Erster Textfeld (als TextFormField)
                  SizedBox(
                    height: screenHeight * 0.15,
                    // Einheitliche Höhe für beide Felder
                    child: TextFormField(
                      controller: _title,
                      maxLength: 50,
                      textAlignVertical: TextAlignVertical.center,
                      style: standardText.copyWith(
                        color: Colors.white,
                        fontSize: screenHeight *
                            0.03, // Einheitliche Schriftgröße
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02, // Mittig ausrichten
                          horizontal: screenWidth * 0.02,
                        ),
                        suffixIcon: Icon(
                          Icons.draw_outlined,
                          color: Colors.white,
                          size: screenHeight * 0.02, // Einheitliche Icon-Größe
                        ),
                        hintText: 'Give your Challenge a name',
                          hintStyle: standardText.copyWith(
                            color: Colors.white,
                            fontSize: screenHeight * 0.03, // Einheitliche Schriftgröße
                            fontStyle: FontStyle.italic
                          ),
                        border: const OutlineInputBorder(),
                        fillColor: Colors.pink,
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please provide a name for your challenge.';
                        }
                        return null;
                      },
                    ),
                  ),
                  // Überschrift für das zweite TextFormField
                  Text(
                    'Description:',
                    style: TextStyle(
                      color: Colors.white,
                      // Sie können die Farbe nach Bedarf anpassen
                      fontSize: screenHeight * 0.03, // Überschrift Größe
                    ),
                    textAlign: TextAlign.center, // Zentrieren der Überschrift
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  // Abstand zwischen Überschrift und TextFormField
                  // Zweiter Textfeld (als TextFormField)
                  SizedBox(
                    height: screenHeight * 0.15,
                    // Einheitliche Höhe für beide Felder
                    child: TextFormField(
                      controller: _description,
                      maxLength: 100,
                      style: standardText.copyWith(
                        color: Colors.white,
                        fontSize: screenHeight *
                            0.03, // Einheitliche Schriftgröße
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02, // Mittig ausrichten
                          horizontal: screenWidth * 0.02,
                        ),
                        suffixIcon: Icon(
                          Icons.draw_outlined,
                          color: Colors.white,
                          size: screenHeight * 0.02, // Einheitliche Icon-Größe
                        ),
                        hintText: 'What is the purpose of this Challenge?',
                        hintStyle: standardText.copyWith(
                            color: Colors.white,
                            fontSize: screenHeight * 0.03, // Einheitliche Schriftgröße
                            fontStyle: FontStyle.italic
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(screenWidth *
                              0.01),
                          borderSide: const BorderSide(color: Colors.black54),
                        ),
                        fillColor: Colors.pink,
                        filled: true,
                      ),
                      keyboardType: TextInputType.multiline,
                      // Ermöglicht den Textumbruch und mehrere Zeilen
                      maxLines: null,
                      // Erlaubt unendlich viele Zeilen
                      minLines: 4,
                      // Mindestanzahl an sichtbaren Zeilen
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please describe the challenge.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Abstand zwischen dem letzten Feld und dem Button
                ],
              ),
            ),
          ),
        ),
        Step(
            title: Text(
              'Commit',
              style: TextStyle(
                color: currentStep == 1 ? Colors.blue[900] : Colors.black,
                fontWeight: currentStep == 1 ? FontWeight.bold : FontWeight
                    .normal,
              ),
            ),
            content: SizedBox(
              height: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                              color: Colors.blueGrey[50], // Background color
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.black54,
                                width: 3,
                              ), // Rounding the corners
                            ),
                            child: const Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        color: Colors.black54),
                                    // Example icon for "Time"
                                    SizedBox(width: 10),
                                    // Spacing between icon and text
                                    Text(
                                      'Time',
                                      style: TextStyle(
                                          fontSize: 20), // Text style
                                    ),
                                  ],
                                ),
                                Text(
                                    '(Duration?)',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                    )
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50], // Background color
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.pink,
                                width: 3,
                              ), // Rounding the corners
                            ),
                            child: const Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.whatshot, color: Colors.pink),
                                    // Example icon for "Intensity"
                                    SizedBox(width: 10),
                                    // Spacing between icon and text
                                    Text(
                                      'Intensity',
                                      style: TextStyle(
                                          fontSize: 20), // Text style
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
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50], // Background color
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.blue.shade900,
                                width: 3,
                              ), // Rounding the corners
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.sports_kabaddi,
                                        color: Colors.blue.shade900),
                                    // Example icon for "Obstacle"
                                    const SizedBox(width: 10),
                                    // Spacing between icon and text
                                    const Text(
                                      'Obstacle',
                                      style: TextStyle(
                                          fontSize: 20), // Text style
                                    ),
                                  ],
                                ),
                                const Text(
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
                          // First text field with associated input field
                          Container(
                            padding: const EdgeInsets.all(5),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50], // Background color
                              borderRadius: BorderRadius.circular(
                                  10), // Rounding the corners
                            ),
                            child: Column(
                              //crossAxisAlignment: CrossAxisAlignment.start, // Align left
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: Row(
                                    children: [
                                      // Minus button
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () {
                                          setState(() {
                                            if (_duration >
                                                0) _duration--; // Decreases the number of days
                                          });
                                        },
                                      ),

                                      // Text field that displays the current value
                                      Expanded(
                                        child: Text(
                                          _duration.toString(),
                                          // Displays the current value of duration
                                          textAlign: TextAlign.center,
                                        ),
                                      ),

                                      // Plus button
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          setState(() {
                                            _duration++; // Increases the number of days
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 15,),

                                      // Dropdown for unit selection
                                      SizedBox(
                                        width: 80,
                                        child: DropdownButtonFormField<String>(
                                          value: _selectedUnit,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                          items: <String>['D', 'W', 'M', 'Y']
                                              .map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (newValue) {
                                            setState(() {
                                              _selectedUnit =
                                                  newValue; // Aktualisiere den Wert im State
                                            });
                                          },
                                          hint: const Text('Unit'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Second text field with dropdown menu
                          Container(
                            padding: const EdgeInsets.all(5),
                            margin: const EdgeInsets.symmetric(vertical: 5),
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
                                    value: _selectedFrequency,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                    items: <String>[
                                      'daily',
                                      'weekly',
                                      'biweekly'
                                    ].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        _selectedFrequency = newValue; // Aktualisiere den Wert im State

                                        // Überprüfe die Auswahl und zeige eine Snackbar, wenn erforderlich
                                        if (newValue == 'weekly' || newValue == 'biweekly') {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Please note that $newValue is mocked and does not work. (You can edit the challenge daily.)'),
                                              duration: Duration(seconds: 4), // Dauer der Snackbar
                                            ),
                                          );
                                        }
                                      });
                                    },
                                    hint: const Text('Select intensity'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Third text field with associated input field
                          Container(
                            padding: const EdgeInsets.all(5),
                            margin: const EdgeInsets.symmetric(vertical: 5),
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
                                    controller: _obstacle,
                                    maxLength: 20,
                                    decoration: const InputDecoration(
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
              'Create',
              style: TextStyle(
                color: currentStep == 2 ? Colors.blue[900] : Colors.black,
                fontWeight: currentStep == 2 ? FontWeight.bold : FontWeight
                    .normal,
              ),
            ),
            content: SizedBox(
              height: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    height: 50,
                    child: ElevatedButton.icon(onPressed: () {
                      print('Add friend');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddFriendToChallenge()),
                      );
                    },
                      icon: const Icon(
                        Icons.add_circle_outline_sharp,
                        size: 25,
                      ),
                      label: const Text(
                          'Add Friends',
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
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Is everything correct?',
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40,),
                  SizedBox(
                    width: 200,
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        bool allFieldsValid = await checkMissingValues();
                        if (allFieldsValid) {
                          await _saveChallenge();
                        }
                      },
                      label: const Text(
                        'Create',
                        style: TextStyle(fontSize: 20),
                      ),
                      icon: const Icon(
                        Icons.done_outline_sharp,
                        size: 20,
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue[900],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
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
                foregroundColor: Colors.blueGrey, // Text color
                backgroundColor: Colors.white, // Background color
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 15), // Inner spacing
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Corner rounding
                ),
              ),
              child: const Icon(
                Icons.keyboard_double_arrow_left_sharp,
                size: 25,
              ),
            ),
            const SizedBox(width: 40), // Spacing between the buttons
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Wenn das Formular gültig ist, weitergehen
                  details.onStepContinue!();
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blueGrey, // Textfarbe
                backgroundColor: Colors.white, // Hintergrundfarbe
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 15), // Innenabstand
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Ecken abrunden
                ),
              ),
              child: const Icon(
                Icons.keyboard_double_arrow_right_sharp,
                size: 25,
              ),
            ),

          ],
        );
      },
    );
  }
}