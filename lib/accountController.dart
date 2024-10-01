import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authentication_provider.dart' as MyAuthProvider;
import 'login.dart';
import 'account_page.dart';
import 'register.dart';
import 'register_details.dart';
import 'edit_account.dart';

/// A stateful widget that manages the account-related pages and navigation.
class MyAccountState extends StatefulWidget {
  const MyAccountState({Key? key}) : super(key: key);

  @override
  _MyAccountState createState() => _MyAccountState();
}

/// Enumeration of the different pages within the account section.
enum CurrentPage { start, login, account, register, registerDetails, editAccount }

class _MyAccountState extends State<MyAccountState> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// The text displayed in the app bar.
  String appBarText = "My Account";

  /// Screen width for responsive layout.
  late double screenWidth;

  /// Screen height for responsive layout.
  late double screenHeight;

  /// The currently active page.
  CurrentPage _currentPage = CurrentPage.start;

  /// Controller for the username input field.
  final TextEditingController _usernameController = TextEditingController();

  /// Controller for the password input field.
  final TextEditingController _passwordController = TextEditingController();

  /// List of interest IDs selected by the user.
  List<int> interests = [1, 2, 3];

  /// Map of all available interests.
  final Map<int, String> allInterests = {};

  /// Temporary storage for username during registration.
  String? tempUsername;

  /// Temporary storage for password during registration.
  String? tempPassword;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  /// Initializes the account state by checking login status and fetching data.
  Future<void> _initialize() async {
    final authProvider = Provider.of<MyAuthProvider.AuthProvider>(context, listen: false);

    try {
      await authProvider.checkLoginStatus();

      if (authProvider.isLoggedIn) {
        if (authProvider.currentUser != null && authProvider.currentUser!.name.isNotEmpty) {
          await _fetchAllInterests();
          setState(() => _currentPage = CurrentPage.account);
        } else {
          final firebaseUser = FirebaseAuth.instance.currentUser;
          if (firebaseUser != null) {
            await authProvider.fetchUserData(firebaseUser.uid);
            if (authProvider.currentUser != null && authProvider.currentUser!.name.isNotEmpty) {
              await _fetchAllInterests();
              setState(() => _currentPage = CurrentPage.account);
            } else {
              setState(() => _currentPage = CurrentPage.login);
            }
          }
        }
      } else {
        setState(() {
          appBarText = "Log In";
          _currentPage = CurrentPage.login;
        });
      }
    } catch (e) {
      setState(() => _currentPage = CurrentPage.login);
    }
  }

  /// Fetches all available interests from the authentication provider.
  Future<void> _fetchAllInterests() async {
    final authProvider = Provider.of<MyAuthProvider.AuthProvider>(context, listen: false);
    final fetchedInterests = await authProvider.fetchAllInterests();
    setState(() => allInterests.addAll(fetchedInterests));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authProvider = Provider.of<MyAuthProvider.AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  appBarText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ),
            ),
            if (authProvider.isLoggedIn) ...[
              // Logout button.
              IconButton(
                icon: const Icon(Icons.logout),
                color: Colors.white,
                iconSize: 30,
                onPressed: () async {
                  final confirmLogout = await showDialog<bool>(
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

                  if (confirmLogout == true) {
                    await authProvider.logout();
                    authProvider.checkLoginStatus();
                    setState(() {
                      appBarText = "Log In";
                      _currentPage = CurrentPage.login;
                    });
                  }
                },
                tooltip: 'Logout',
              ),
              // Edit account button.
              IconButton(
                icon: const Icon(Icons.edit),
                color: Colors.white,
                iconSize: 30,
                onPressed: () {
                  setState(() => _currentPage = CurrentPage.editAccount);
                },
                tooltip: 'Edit Account',
              ),
            ],
          ],
        ),
        // Gradient background for the app bar.
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
          return Center(child: _getCurrentPage(authProvider));
        },
      ),
    );
  }

  /// Returns the widget corresponding to the current page state.
  Widget _getCurrentPage(MyAuthProvider.AuthProvider authProvider) {
    switch (_currentPage) {
      case CurrentPage.login:
        appBarText = "Log In";
        return LoginPage(
          usernameController: _usernameController,
          passwordController: _passwordController,
          onLogin: () async {
            await _fetchAllInterests();
            setState(() {
              appBarText = "My Account";
              _currentPage = CurrentPage.account;
            });
          },
          onNavigateToRegister: () {
            setState(() {
              appBarText = "Register";
              _currentPage = CurrentPage.register;
            });
          },
        );
      case CurrentPage.account:
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
          return const Text('User data not found. Please log in again.');
        }
      case CurrentPage.register:
        return RegisterPage(
          onRegister: (username, password) async {
            await _fetchAllInterests(); // Fetch interests before navigating
            setState(() {
              appBarText = "Register Details";
              tempUsername = username;
              tempPassword = password;
              _currentPage = CurrentPage.registerDetails;
            });
          },
        );
      case CurrentPage.registerDetails:
        appBarText = "Complete Registration";
        return RegisterDetailsPage(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          tempUsername: tempUsername!,
          tempPassword: tempPassword!,
          allInterests: allInterests, // Ensure this line exists
          onRegistrationComplete: () async {
            await _fetchAllInterests();
            setState(() => _currentPage = CurrentPage.account);
          },
          onBack: () { // Handler for navigating back to the register page.
            setState(() {
              appBarText = "Register";
              _currentPage = CurrentPage.register;
            });
          },
        );
      case CurrentPage.editAccount:
      // Render edit account page and pass the onUpdate callback.
        return EditAccountPage(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          authProvider: authProvider,
          onUpdate: (String newUserName, String newEmail, String newDescription, List<int> newInterests) {
            // Update state to go back to the account page after a successful update.
            setState(() {
              _currentPage = CurrentPage.account;

              // Optionally, update the user data in the state if needed.
              authProvider.currentUser!.name = newUserName;
              authProvider.currentUser!.email = newEmail;
              authProvider.currentUser!.shortDescription = newDescription;
              authProvider.currentUser!.interests = newInterests;
            });
          },
        );
      default:
        return startWidget();
    }
  }

  /// Displays a loading widget while the current page is being determined.
  Widget startWidget() {
    return Scaffold(
      backgroundColor: Colors.blueGrey[400],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Loading...',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
