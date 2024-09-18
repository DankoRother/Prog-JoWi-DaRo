import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authentication_provider.dart';
import 'current_challenges.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import the new widget files
import 'login.dart';
import 'account_page.dart';
import 'register.dart';
import 'register_details.dart';
import 'edit_account.dart';
import 'interest_selection.dart';

class MyAccountState extends StatefulWidget {
  const MyAccountState({super.key});

  @override
  _MyAccountState createState() => _MyAccountState();
}

enum CurrentPage { login, account, register, registerDetails }

class _MyAccountState extends State<MyAccountState> {
  CurrentPage? _currentPage; // Make it nullable
  String userName = 'Danko Rother';
  String email = 'john.doe@example.com';
  String shortDescription = 'Avid runner and coffee enthusiast.';
  int completedChallenges = 5;
  late double screenWidth;
  late double screenHeight;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  List<int> interests = [1, 2, 3];
  final Map<int, String> allInterests = {};

  String? tempUsername;
  String? tempPassword;
  @override
  void initState() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    super.initState();
    _fetchAllInterests();
    authProvider.checkLoginStatus(context).then((_) {
      setState(() {
        _currentPage = authProvider.isLoggedIn ? CurrentPage.account : CurrentPage.login;
      });
    }); // Close the .then() block here
  } // Close the initState() method here

  Future<void> _fetchAllInterests() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final fetchedInterests = await authProvider.fetchAllInterests();
    setState(() {
      allInterests.addAll(fetchedInterests);
    });
  }

  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        // ... (AppBar code remains the same)
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              screenWidth = constraints.maxWidth;
              screenHeight = constraints.maxHeight;
              return Center(
                child: _getCurrentPage()
              );
            },
          );
        },
      ),
    );
  }

  Widget _getCurrentPage() {
    void navigateToRegister() {
      setState(() {
        _currentPage = CurrentPage.register;
      });
    }
    switch (_currentPage) {
      case CurrentPage.login:
        return LoginPage(
          usernameController: _usernameController,
          passwordController: _passwordController,
          onLogin: () {
            setState(() {
              _currentPage = CurrentPage.account;
            });
          },
          onNavigateToRegister: navigateToRegister, // Pass the callback here
        );
      case CurrentPage.account:
        return AccountPage(
          userName: userName,
          email: email,
          shortDescription: shortDescription,
          completedChallenges: completedChallenges,
          interests: interests,
          allInterests: allInterests,
        );
      case CurrentPage.register:
        return RegisterPage(
            onRegister: (username, password) {
              setState(() {
                tempUsername = username;
                tempPassword = password;
                _currentPage = CurrentPage.registerDetails;
              });
            }
        );
      case CurrentPage.registerDetails:
        return RegisterDetailsPage(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          tempUsername: tempUsername!,
          tempPassword: tempPassword!,
          allInterests: allInterests,
        );
      default:
        return Container();
    }
  }

  Widget _buildAccountPage(double screenWidth, double screenHeight) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.fetchUserData().then((userData) {
      setState(() {
        userName = userData['name'];
        email = userData['email'];
        shortDescription = userData['shortDescription'];
        interests = List<int>.from(userData['interests']);
      });
    });

    return AccountPage(
      userName: userName,
      email: email,
      shortDescription: shortDescription,
      completedChallenges: completedChallenges,
      interests: interests,
      allInterests: allInterests,
    );
  }

  Widget _buildEditAccountPage(BuildContext context, AuthProvider authProvider) {
    return EditAccountPage(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      authProvider: authProvider,
      userName: userName,
      email: email,
      shortDescription: shortDescription,
      interests: interests,
      allInterests: allInterests,
      onUpdate: (newUserName, newEmail, newShortDescription, newInterests) {
        setState(() {
          userName = newUserName;
          email = newEmail;
          shortDescription = newShortDescription;
          interests = newInterests;
        });
      },
    );
  }


  Widget _buildInterestSelectionDialog(BuildContext context, List<int> dialogSelectedInterests) {
    return InterestSelectionDialog(
        allInterests: allInterests,
        selectedInterests: dialogSelectedInterests
    );
  }
}