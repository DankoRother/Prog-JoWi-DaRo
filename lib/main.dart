import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'settings.dart';
import 'current_challenges.dart';
import 'create_challenges.dart';
import 'welcome_screen.dart';
import 'my_account.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Something family friendly', // Translated from 'Etwas Familienfreundliches'
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        scaffoldBackgroundColor: Colors.blueGrey[400],
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: true,
      home: WelcomeScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

double screenHeight = 1440.0; // Default value, so that nothing happens in case of missing initialization
double screenWidth = 3168.0; // Default value, so that nothing happens in case of missing initialization
double screenWidthAndHeight = screenWidth+screenHeight;
late TextStyle standardText;  // Standard TextStyle: Can be overwritten with "standardText.copyWith(data-to-be-overwritten)" if necessary

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 2;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenHeight = MediaQuery.of(context).size.height;  // Set the screen height
    screenWidth = MediaQuery.of(context).size.width;    // Set the screen width
    screenWidthAndHeight = screenWidth+screenHeight;
    standardText = TextStyle(                           // TODO: Develop font style that fits the application
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
        page = MyAccountState();
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
            label: 'Account',
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
          // The container with the page content
          Align(
            alignment: Alignment.topCenter,  // Horizontal centering, arranged at the top
            child: Container(
              width: screenWidth * 0.75,  // Fixed width
              margin: EdgeInsets.only(top: screenHeight * 0.04),  // Spacing from the top
              padding: EdgeInsets.all(screenWidth * 0.02),  // Inner spacing
              decoration: BoxDecoration(
                color: Colors.indigoAccent,  // Background color of the container
                borderRadius: BorderRadius.circular(screenWidth * 0.4*0.08),  // Rounding the corners
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,  // Minimizes the size of the column
                children: [
                  Text(
                    'Your Challenges',
                    style: standardText.copyWith(fontWeight: FontWeight.bold, fontSize: screenHeight*0.03),  // Text style heading
                    textAlign: TextAlign.center,  // Text centering
                  ),
                  SizedBox(height: screenHeight * 0.02),  // Spacing between text and first text field
                  TextField(
                    decoration: InputDecoration(
                      hintStyle: standardText.copyWith(fontSize: screenWidth*0.04, color: Colors.black),
                      hintText: 'Height: $screenHeight width: $screenWidth', // Display the dimensions for development TODO: Remove before final product
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(vertical: screenWidth*0.01, horizontal: screenWidth*0.02),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),  // Spacing between the text fields
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
                  SizedBox(height: screenHeight * 0.01),  // Spacing between the text fields
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
                  SizedBox(height: screenHeight * 0.02),  // Spacing between the last text field and the button
                  ElevatedButton.icon(onPressed: () {
                    print('Button pressed'); // Translated from 'Button gedrückt'
                  },
                    icon: Icon(Icons.favorite_border),
                    label: Text('Like',style: standardText.copyWith(fontWeight: FontWeight.bold, fontSize: screenHeight * 0.03)),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blueGrey,   // Button text color
                      padding: EdgeInsets.only(right: screenWidth * 0.025, left: screenWidth*0.025, top: screenHeight * 0.005, bottom: screenHeight * 0.005), // Button inner spacing
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Rounding the corners
                      ),
                    ),

                  )
                ],
              ),
            ),
          ),

          // Settings icon top left
          Positioned(
            top: screenWidth * 0.008,  // Spacing from the top (including status bar)
            left: screenWidth * 0.008,  // Spacing from the left
            child: IconButton(
              icon: Icon(Icons.settings),
              color: Colors.white,  // Color of the icon
              iconSize: screenWidthAndHeight*0.025,  // Size of the icon
              onPressed: () {
                // Here comes the navigation to the settings page
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