import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authentication_provider.dart'; // Importiere den AuthProvider
import 'current_challenges.dart'; // Importiere die aktuelle Challenge-Seite
import 'main.dart'; // Importiere die Standard Text-Stile oder andere nützliche Dinge
import 'package:cloud_firestore/cloud_firestore.dart';
class MyAccountState extends StatefulWidget {
  const MyAccountState({super.key});

  @override
  _MyAccountState createState() => _MyAccountState();
}
enum CurrentPage { login, account, register, registerDetails }
bool showRegisterDetails = false;
class _MyAccountState extends State<MyAccountState> {

  String userName = 'Danko Rother';
  String email = 'john.doe@example.com';
  String shortDescription = 'Avid runner and coffee enthusiast.';
  int completedChallenges = 5;
  late double screenWidth;
  late double screenHeight;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  List<int> interests = [1, 2, 3];
  CurrentPage _currentPage = CurrentPage.login;
  final Map<int, String> allInterests = {}; // Initialize as an empty map

  @override
  void initState() {
    super.initState();
    _fetchAllInterests();
  }

  // Move _fetchAllInterests inside the _MyAccountState class
  Future<void> _fetchAllInterests() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final fetchedInterests = await authProvider.fetchAllInterests();
    setState(() {
      allInterests.addAll(fetchedInterests); // Update the allInterests map
    });
  }
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink, Colors.blueGrey.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: isLoggedIn
            ? const Text(
          "My Account",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        )
            : const Text(
          "Log In",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        actions: isLoggedIn
            ? [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    child: Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.15,
                            horizontal: screenWidth * 0.1),
                        child: _buildEditAccountPage(context, authProvider),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            onPressed: () {
              authProvider.logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ]
            : null,
      ),
      body: Consumer<AuthProvider>( // Wrap the body with Consumer
        builder: (context, authProvider, child) {
          return LayoutBuilder( // Nest LayoutBuilder inside Consumer
            builder: (BuildContext context, BoxConstraints constraints) {
              screenWidth = constraints.maxWidth;
              screenHeight = constraints.maxHeight;
              return Center(
                child: authProvider.isLoggedIn
                    ? _buildAccountPage(screenWidth, screenHeight)
                    : _getCurrentPage(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getCurrentPage() {
    switch (_currentPage) {
      case CurrentPage.login:
        return _buildLoginPage(screenWidth, screenHeight);
      case CurrentPage.account:
        return _buildAccountPage(screenWidth, screenHeight);
      case CurrentPage.register:
        return _buildRegisterPage(screenWidth, screenHeight);
      case CurrentPage.registerDetails:
        return _buildRegisterDetailsPage(screenWidth, screenHeight);
      default:
        return Container(); // Or any other suitable Widget as a fallback
    }
  }

  Widget _buildAccountPage(double screenWidth, double screenHeight) { // Fetch user data and interests when the page builds
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.fetchUserData().then((userData) {
      setState(() {
        userName = userData['name'];
        email = userData['email'];
        shortDescription = userData['shortDescription'];
        interests = List<int>.from(userData['interests']);
      });
    });
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: screenHeight * 0.04),
        CircleAvatar(
          radius: screenHeight * 0.07,
          backgroundImage: const AssetImage(
              'assets/images/profile_placeholder.png'),
        ),
        SizedBox(height: screenHeight * 0.022),
        Container(
          padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.012, horizontal: screenWidth * 0.07),
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                textAlign: TextAlign.center,
                maxLines: 1,
                userName,
                style: standardText.copyWith(
                  fontSize: standardText.fontSize! * 1.4,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.005),
              Text(
                textAlign: TextAlign.center,
                shortDescription,
                style: standardText.copyWith(color: Colors.grey[300]),
              ),
              SizedBox(height: screenHeight * 0.010),
              Text(
                textAlign: TextAlign.center,
                email,
                style: standardText.copyWith(color: Colors.grey),
              ),
              SizedBox(height: screenHeight * 0.025),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                    WidgetStateProperty.all(Colors.blue[900])),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CurrentChallenges()),
                  );
                },
                child: Text(
                  textAlign: TextAlign.center,
                  "Laufende Challenges",
                  style: standardText,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              Text(
                textAlign: TextAlign.center,
                "Abgeschlossene Challenges: $completedChallenges",
                style: standardText.copyWith(
                  fontSize: standardText.fontSize! * 1.2,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              // Display interests
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: interests.map((interestId) {
                  return Chip(
                    label: Text(allInterests[interestId]!),
                    backgroundColor: Colors.blueGrey[300],
                  );
                }).toList(),
              ),
              SizedBox(height: screenHeight * 0.005),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginPage(double screenWidth, double screenHeight) {
    void attemptLogin() async {
      if (_usernameController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty) {
        try {
          // Get the AuthProvider instance
          final authProvider = Provider.of<AuthProvider>(context, listen: false);

          // Call attemptLogin on the authProvider
          await authProvider.attemptLogin(
            context,
            _usernameController.text,
            _passwordController.text,
          );

          // If login is successful, you might want to navigate to the account page
          if (authProvider.isLoggedIn) {
            setState(() {
              _currentPage = CurrentPage.account;
            });
          }
        } catch (e) {
          // Error handling
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error during login: $e'),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.pink[700],
            content: Text('Please fill in all fields.'),
          ),
        );
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username' + error),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              onSubmitted: (_) => attemptLogin(),
            ),
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.blue[900]),
            ),
            onPressed: () {
              attemptLogin();
            },
            child: Text(
              'Login',
              style: standardText,
            ),
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(
                  Colors.green[700]), // Or any color you prefer
            ),
            onPressed: () {
              // Navigate to the registration page
              setState(() {
                _currentPage = CurrentPage.register;
              });
            },
            child: Text(
              'Register',
              style: standardText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditAccountPage(BuildContext context,
      AuthProvider authProvider) {
    final TextEditingController userNameController =
    TextEditingController(text: userName);
    final TextEditingController emailController =
    TextEditingController(text: email);
    final TextEditingController shortDescriptionController =
    TextEditingController(text: shortDescription);
    List<int> selectedInterests = List.from(interests ?? []);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey.shade400, Colors.pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text("Edit Account"),
      ),
      body: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: screenHeight * 0.04),
                  CircleAvatar(
                    radius: screenHeight * 0.07,
                    backgroundImage: const AssetImage(
                        'assets/images/profile_placeholder.png'),
                  ),
                  SizedBox(height: screenHeight * 0.022),
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.012,
                        horizontal: screenWidth * 0.014),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        // Editable username field
                        TextField(
                          controller: userNameController,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: standardText.copyWith(
                            fontSize: standardText.fontSize! * 1.4,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter new username',
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        // Editable email field
                        TextField(
                          controller: emailController,
                          textAlign: TextAlign.center,
                          style: standardText.copyWith(
                              fontWeight: FontWeight.normal,
                              color: Colors.grey[800]
                          ),
                          decoration: InputDecoration(
                              hintText: 'Enter new email',
                              filled: true,
                              fillColor: Colors.blueGrey[300]
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.001),
                        // Short description field
                        TextField(
                          controller: shortDescriptionController,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          maxLength: 200,
                          style: standardText.copyWith(
                              fontWeight: FontWeight.normal),
                          decoration: InputDecoration(
                              hintText: 'Enter a short description about yourself',
                              filled: true,
                              fillColor: Colors.blueGrey[300]
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.025),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Submit Changes button
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                    Colors.blue[900]),
                              ),
                              onPressed: () {
                                // Update user data and interests in the AuthenticatorProvider
                                setState(() {
                                  userName = userNameController.text;
                                  email = emailController.text;
                                  shortDescription =
                                      shortDescriptionController.text;
                                  interests = List.from(
                                      selectedInterests); // Update the main interests list
                                });

                                Navigator.pop(context);
                              },
                              child: Text(
                                textAlign: TextAlign.center,
                                "Submit Changes",
                                style: standardText,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        // Display and edit interests
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: selectedInterests.map((interestId) {
                            return Chip(
                              label: Text(allInterests[interestId]!),
                              backgroundColor: Colors.blueGrey[300],
                              onDeleted: () {
                                // Remove interest from the local selectedInterests list and rebuild the widget
                                setState(() {
                                  selectedInterests.remove(interestId);
                                });
                              },
                            );
                          }).toList(),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        ElevatedButton(
                          onPressed: () async {
                            final List<
                                int>? newSelectedInterests = await showDialog<
                                List<int>>(
                              context: context,
                              builder: (BuildContext context) {
                                return _buildInterestSelectionDialog(
                                    context, selectedInterests);
                              },
                            );

                            if (newSelectedInterests != null &&
                                newSelectedInterests.isNotEmpty) {
                              setState(() {
                                selectedInterests = newSelectedInterests;
                                // Ensure we don't exceed the maximum of 3 interests
                                selectedInterests = selectedInterests.sublist(0,
                                    selectedInterests.length > 3
                                        ? 3
                                        : selectedInterests.length);
                              });
                            }
                          },
                          child: const Text('Add Interest'),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                      ],
                    ),
                  ),
                ],
              )
          );
        },
      ),
    );
  }

  String? tempUsername;
  String? tempPassword;

  Widget _buildRegisterPage(double screenWidth, double screenHeight) {
    final _usernameController = TextEditingController();
    final _passwordController = TextEditingController();

    void proceedToDetails() async {
      // Basic validation
      if (_usernameController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty) {
        try {
          // Check if username already exists
          final querySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: _usernameController.text)
              .get();
          if (querySnapshot.docs.isEmpty) {
            // Username is available, store temporarily and proceed
            setState(() {
              tempUsername = _usernameController.text;
              tempPassword = _passwordController.text;
              _currentPage = CurrentPage.registerDetails;
            });
          } else {
            // Username already exists, show error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.pink[700],
                content: Text('Username already taken.'),
              ),
            );
          }
        } catch (e) {
          // Error handling
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error during registration: $e'),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.pink[700],
            content: Text('Please fill in all fields.'),
          ),
        );
      }
    }
    return Scaffold( // Wrap the content with Scaffold
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  onSubmitted: (_) => proceedToDetails(),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.blue[900]),
              ),
              onPressed: () {
                proceedToDetails();
              },
              child: Text(
                'Register',
                style: standardText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterDetailsPage(double screenWidth, double screenHeight) {
    final TextEditingController userNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController shortDescriptionController = TextEditingController();
    List<int> selectedInterests = [];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey.shade400, Colors.pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text("Complete Registration"),
      ),
      body: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: screenHeight * 0.04),
                CircleAvatar(
                  radius: screenHeight * 0.07,
                  backgroundImage: const AssetImage(
                      'assets/images/profile_placeholder.png'),
                ),
                SizedBox(height: screenHeight * 0.022),
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.012,
                    horizontal: screenWidth * 0.014,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      // Editable name field
                      TextField(
                        controller: userNameController,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: standardText.copyWith(
                          fontSize: standardText.fontSize! * 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Enter your name',
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.001),
                      // Editable email field
                      TextField(
                        controller: emailController,
                        textAlign: TextAlign.center,
                        style: standardText.copyWith(
                          fontWeight: FontWeight.normal,
                          color: Colors.grey[800],
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          filled: true,
                          fillColor: Colors.blueGrey[300],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.001),
                      // Short description field
                      TextField(
                        controller: shortDescriptionController,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        maxLength: 200,
                        style: standardText.copyWith(
                          fontWeight: FontWeight.normal,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter a short description about yourself',
                          filled: true,
                          fillColor: Colors.blueGrey[300],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.025),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Display and edit interests
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: selectedInterests.map((interestId) {
                              return Chip(
                                label: Text(allInterests[interestId]!),
                                backgroundColor: Colors.blueGrey[300],
                                onDeleted: () {
                                  setState(() {
                                    selectedInterests.remove(interestId);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          ElevatedButton(
                            onPressed: () async {
                              final List<
                                  int>? newSelectedInterests = await showDialog<
                                  List<int>>(
                                context: context,
                                builder: (BuildContext context) {
                                  return _buildInterestSelectionDialog(
                                      context, selectedInterests);
                                },
                              );

                              if (newSelectedInterests != null &&
                                  newSelectedInterests.isNotEmpty) {
                                setState(() {
                                  selectedInterests = newSelectedInterests;
                                  selectedInterests = selectedInterests.sublist(
                                    0,
                                    selectedInterests.length > 3
                                        ? 3
                                        : selectedInterests.length,
                                  );
                                });
                              }
                            },
                            child: Text('Add interests'),
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          // Complete Registration button
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  Colors.blue[900]),
                            ),
                            onPressed: () {
                              final authProvider = Provider.of<AuthProvider>(context, listen: false);
                              authProvider.attemptRegister(
                                context,
                                tempUsername!,
                                tempPassword!,
                                userNameController.text,
                                emailController.text,
                                shortDescriptionController.text,
                                selectedInterests,
                              );
                            },
                              child: Text(
                                textAlign: TextAlign.center,
                                "Complete Registration",
                                style: standardText,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.015),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  Widget _buildInterestSelectionDialog(BuildContext context,
      List<int> dialogSelectedInterests) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return AlertDialog(
          title: const Text('Select Interests'),
          content: SingleChildScrollView(
            child: Column(
              children: allInterests.entries
                  .where((entry) =>
              !dialogSelectedInterests.contains(entry.key))
                  .map((entry) {
                return CheckboxListTile(
                  title: Text(entry.value),
                  value: dialogSelectedInterests.contains(entry.key),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value!) {
                        dialogSelectedInterests.add(entry.key);
                      } else {
                        dialogSelectedInterests.remove(entry.key);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(dialogSelectedInterests);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}