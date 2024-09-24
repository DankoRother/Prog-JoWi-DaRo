import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authentication_provider.dart' as MyAuthProvider;
import 'login.dart';
import 'account_page.dart';
import 'register.dart';
import 'register_details.dart';

class MyAccountState extends StatefulWidget {
  const MyAccountState({super.key});

  @override
  _MyAccountState createState() => _MyAccountState();
}

enum CurrentPage { start, login, account, register, registerDetails }

class _MyAccountState extends State<MyAccountState> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  String AppBarText = "My Account";
  late double screenWidth;
  late double screenHeight;
  CurrentPage _currentPage = CurrentPage.start; // Declare _currentPage
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  List<int> interests = [1, 2, 3];
  final Map<int, String> allInterests = {};
  String? tempUsername;
  String? tempPassword;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final authProvider = Provider.of<MyAuthProvider.AuthProvider>(context, listen: false); // Fetch the existing AuthProvider instance

    try {
      print('Starting login status check...');
      await authProvider.checkLoginStatus(); // Check if user is logged in

      if (authProvider.isLoggedIn) {
        print('User is logged in');
        AppBarText = "My Account";
        // Ensure that valid user data exists, otherwise, fetch it
        if (authProvider.currentUser != null && authProvider.currentUser!.name.isNotEmpty) {
          print('User data is available: ${authProvider.currentUser!.name}');
          await _fetchAllInterests(); // Fetch interests
          setState(() {
            _currentPage = CurrentPage.account; // Move to account page
          });
        } else {
          // Fetch the user data if it's missing or incomplete
          final firebaseUser = FirebaseAuth.instance.currentUser;
          if (firebaseUser != null) {
            await authProvider.fetchUserData(firebaseUser.uid);

            if (authProvider.currentUser != null && authProvider.currentUser!.name.isNotEmpty) {
              print('Fetched user data successfully: ${authProvider.currentUser!.name}');
              await _fetchAllInterests(); // Fetch interests
              setState(() {
                _currentPage = CurrentPage.account; // Move to account page
              });
            } else {
              // User data is still missing, fallback to login
              print('Failed to fetch valid user data, fallback to login.');
              setState(() {
                _currentPage = CurrentPage.login;
              });
            }
          }
        }
      } else {
        print('User is not logged in.');
        setState(() {
          AppBarText = "Log In";
          _currentPage = CurrentPage.login; // Set to login if not logged in
        });
      }
    } catch (e) {
      print('Error during initialization: $e');
      setState(() {
        _currentPage = CurrentPage.login; // Fallback to login in case of error
      });
    }
  }



  Future<void> _fetchAllInterests() async {
    final authProvider = Provider.of<MyAuthProvider.AuthProvider>(context, listen: false);
    final fetchedInterests = await authProvider.fetchAllInterests();
    setState(() {
      allInterests.addAll(fetchedInterests);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // This is needed when using AutomaticKeepAliveClientMixin
    final authProvider = Provider.of<MyAuthProvider.AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.center,
              child: Text(
                '$AppBarText',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            if (authProvider.isLoggedIn)
              IconButton(
                icon: const Icon(Icons.logout),
                color: Colors.white,
                iconSize: 30,
                onPressed: () async {
                  // Show a confirmation dialog before logging out
                  bool? confirmLogout = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Logout"),
                        content: const Text("Are you sure you want to log out?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("Logout"),
                          ),
                        ],
                      );
                    },
                  );

                  // If the user confirms, log out
                  if (confirmLogout == true) {
                    await authProvider.logout();
                    if (authProvider.currentUser != null) {
                      authProvider.logout();
                    }
                    authProvider.checkLoginStatus();

                    // Trigger a state update to re-render the widget after logging out
                    setState(() {
                      AppBarText = "Log In";
                      confirmLogout = false;
                      _currentPage = CurrentPage.login;
                    });
                  }
                },
                tooltip: 'Logout',
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

      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          screenWidth = constraints.maxWidth;
          screenHeight = constraints.maxHeight;

          // Keep using the _getCurrentPage function to display the content
          return Center(
            child: _getCurrentPage(authProvider),
          );
        },
      ),
    );
  }



  Widget _getCurrentPage(MyAuthProvider.AuthProvider authProvider) {
    // Render the page based on the value of `_currentPage`
    switch (_currentPage) {
      case CurrentPage.login:
        AppBarText = "Log In";
        print('Displaying login page...');
        return LoginPage(
          usernameController: _usernameController,
          passwordController: _passwordController,
          onLogin: () async {
            print('Navigating to Account Page after successful login');
            await _fetchAllInterests(); // Fetch interests after login
            setState(() {
              AppBarText = "My Account";
              _currentPage = CurrentPage.account;
            });
          },
          onNavigateToRegister: () {
            setState(() {
              AppBarText = "Register";
              _currentPage = CurrentPage.register;
            });
          },
        );
      case CurrentPage.account:
        print('Displaying account page...');
        final currentUser = authProvider.currentUser;
        if (currentUser != null && currentUser.name.isNotEmpty) {
          authProvider.checkLoginStatus();
          return AccountPage(
            userName: currentUser.name,
            email: currentUser.email,
            shortDescription: currentUser.shortDescription,
            completedChallenges: currentUser.completedChallenges,
            interests: currentUser.interests,
            allInterests: allInterests,
          );
        } else {
          print('User data is invalid, cannot display account page.');
          return const Text('User data not found. Please log in again.');
        }
      case CurrentPage.register:
        print('Displaying register page...');
        return RegisterPage(
          onRegister: (username, password) {
            setState(() {
              AppBarText = "Register";
              tempUsername = username;
              tempPassword = password;
              _currentPage = CurrentPage.registerDetails;
            });
          },
        );
      case CurrentPage.registerDetails:
        AppBarText = "Complete Registration";
        print('Displaying register details page...');
        return RegisterDetailsPage(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          tempUsername: tempUsername!,
          tempPassword: tempPassword!,
          allInterests: allInterests,
          onRegistrationComplete: () async {
            await _fetchAllInterests(); // Fetch interests after registration
            setState(() {
              _currentPage = CurrentPage.account;
            });
          },
        );
      default:
        return startWidget(); // Fallback in case of unknown state
    }
  }

  Widget startWidget() {
    return Scaffold(
      backgroundColor: Colors.blueGrey[400], // Gray background color consistent with the app theme
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(), // Loading spinner
            SizedBox(height: 20),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white, // White text to contrast with the gray background
              ),
            ),
          ],
        ),
      ),
    );
  }

}
