import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prog2_jowi_daro/addfriend_createchallenge.dart';
import 'package:prog2_jowi_daro/friends.dart';
import 'package:provider/provider.dart';
import 'authentication_provider.dart' as MyAuthProvider;
import 'current_challenges.dart';
import 'create_challenges.dart';
import 'welcome_screen.dart';
import 'accountController.dart';
import 'chatScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'chatBot_service.dart';
import 'package:google_fonts/google_fonts.dart';


String error = "abc";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase before running the app
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Ensure Firebase Auth persistence
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

  // Wrap the app with MultiProvider and provide AuthProvider globally
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyAuthProvider.AuthProvider()), // AuthProvider provided globally
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

// Use StatefulWidget and WidgetsBindingObserver to monitor app lifecycle
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


// This method listens to app lifecycle state changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // When the app is resumed, only check if the user was previously logged in
      final authProvider = Provider.of<MyAuthProvider.AuthProvider>(context, listen: false);
      if (authProvider.isLoggedIn) {
        authProvider.checkLoginStatus(); // Recheck the user's login status only if logged in
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'challengr - beat your habits',
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/currentChallenges': (context) => const CurrentChallenges(),
        '/account': (context) => const MyAccountState(), // Added account route
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

double screenHeight = 1440.0;
double screenWidth = 3168.0;
double screenWidthAndHeight = screenWidth + screenHeight;
late TextStyle standardText;

class MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 2;
  bool _isAccountInitialized = false;

  final List<Widget> _pages = [
    ChatScreen(),
    Friends(),
    const CreateChallenge(),
    const CurrentChallenges(),
    const MyAccountState(), // Account page
  ];

  void navigateToPage(int index) {
    setState(() {
      selectedIndex = index;
      if (index == 4 && !_isAccountInitialized) {
        _initializeMyAccountState(); // Only reinitialize if not already done
      }
    });
  }

  Future<void> _initializeMyAccountState() async {
    final authProvider = Provider.of<MyAuthProvider.AuthProvider>(context, listen: false);

    // First, ensure the user is logged in and data is loaded
    await authProvider.checkLoginStatus();

    // If the user is logged in, skip calling fetchUserData again
    if (authProvider.isLoggedIn && authProvider.currentUser != null) {
      setState(() {
        _isAccountInitialized = true;
        _pages[4] = const MyAccountState(); // Reload the account page
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    screenWidthAndHeight = screenWidth + screenHeight;
    standardText = TextStyle(
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
        color: Theme
            .of(context)
            .colorScheme
            .primaryContainer,
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
            label: 'ChatBot',
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

