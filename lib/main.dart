import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authentication_provider.dart';
import 'current_challenges.dart';
import 'create_challenges.dart';
import 'welcome_screen.dart';
import 'my_account.dart';
import 'chat.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
String error = "abc";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options:
    DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
  // Get all documents
  FirebaseFirestore.instance
      .collection('userbase')
      .get()
      .then((QuerySnapshot querySnapshot) {
    for (var doc in querySnapshot.docs) {
      print(doc.data());

  }
  });
  try {
    final userCollection = FirebaseFirestore.instance.collection('userbase');
    await userCollection.add({
      'username': 'johannes',
      'description': 'test',
      'email': 'testuser@test.com',
      'password': 'testtest',
    });
      } catch (e) {

    error = " $e";
  }
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'challengr - beat your habits',
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/currentChallenges': (context) => const CurrentChallenges(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        scaffoldBackgroundColor: Colors.blueGrey[400],
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      //home: WelcomeScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

double screenHeight = 1440.0; // Default value, so that nothing happens in case of missing initialization
double screenWidth = 3168.0; // Default value, so that nothing happens in case of missing initialization
double screenWidthAndHeight = screenWidth+screenHeight;
late TextStyle standardText;  // Standard TextStyle: Can be overwritten with "standardText.copyWith(data-to-be-overwritten)" if necessary

class MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 2;

  final List<Widget> _pages = [
    const YourChallenges(),
    const Placeholder(),
    const CreateChallenge(),
    const CurrentChallenges(),
    const MyAccountState()
  ];

  void navigateToPage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

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
    /*Widget page;
    switch (selectedIndex) {
      case 0:
        page = const YourChallenges();
        break;
      case 1:
        page = const Placeholder();
        break;
      case 2:
        page = const CreateChallenge();
        break;
      case 3:
        page = const CurrentChallenges();
        break;
      case 4:
        page = const MyAccountState();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }*/

    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: _pages[selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          navigateToPage(index);
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

