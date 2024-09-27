import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authentication_provider.dart' as MyAuthProvider;
import 'login.dart';
import 'account_page.dart';
import 'register.dart';
import 'register_details.dart';
import 'edit_account.dart';

class MyAccountState extends StatefulWidget {
  const MyAccountState({Key? key}) : super(key: key);

  @override
  _MyAccountState createState() => _MyAccountState();
}

enum CurrentPage { start, login, account, register, registerDetails, editAccount }

class _MyAccountState extends State<MyAccountState> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String appBarText = "My Account";
  late double screenWidth;
  late double screenHeight;
  CurrentPage _currentPage = CurrentPage.start;
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
          onRegister: (username, password) {
            setState(() {
              appBarText = "Register";
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
          allInterests: allInterests,
          onRegistrationComplete: () async {
            await _fetchAllInterests();
            setState(() => _currentPage = CurrentPage.account);
          },
        );
      case CurrentPage.editAccount:
      // Render edit account page and pass the onUpdate callback
        return EditAccountPage(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          authProvider: authProvider,
          onUpdate: (String newUserName, String newEmail, String newDescription, List<int> newInterests) {
            // Update state to go back to the account page after a successful update
            setState(() {
              _currentPage = CurrentPage.account;

              // Optionally, update the user data in the state if needed
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
